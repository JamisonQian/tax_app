import 'package:flutter_test/flutter_test.dart';

import 'package:tax_app/models.dart';

void main() {
  group('generateTaxRecords 累计预扣预缴计算', () {
    test('月收入 10000，7 个月，全部在 3% 档', () {
      final config = QueryConfig(
        agent: '测试公司',
        monthlyIncome: 10000,
        startMonth: DateTime(2026, 1),
        endMonth: DateTime(2026, 7),
      );
      final records = generateTaxRecords(config);

      expect(records.length, 7);
      // 月份倒序：最新在最上面
      expect(records.first.month, '2026-07');
      expect(records.last.month, '2026-01');

      // 每月应纳税所得额 5000，税额 150
      for (final r in records) {
        expect(r.taxAmount, 150.0);
      }

      // 总税额 = 1050
      final total = records.fold<double>(0, (s, r) => s + r.taxAmount);
      expect(total, 1050.0);
    });

    test('月收入 20000，10 个月，第 10 个月跨入 10% 档', () {
      final config = QueryConfig(
        agent: '测试公司',
        monthlyIncome: 20000,
        startMonth: DateTime(2026, 1),
        endMonth: DateTime(2026, 10),
      );
      final records = generateTaxRecords(config);

      // 第 9 个月：累计应纳税所得额 135000 → 累计税 135000×10%-2520 = 10980
      // 第 10 个月：累计 150000，跨入 20% 档 → 累计税 150000×20%-16920 = 13080
      // 当月税额 = 13080 - 10980 = 2100
      expect(records.last.month, '2026-01');
      expect(records.first.month, '2026-10');
      expect(records.first.taxAmount, 2100.0);

      // 累计税额总和 = 13080
      final total = records.fold<double>(0, (s, r) => s + r.taxAmount);
      expect(total, 13080.0);
    });

    test('月收入 4000，低于减除费用，税额为 0', () {
      final config = QueryConfig(
        agent: '测试公司',
        monthlyIncome: 4000,
        startMonth: DateTime(2026, 1),
        endMonth: DateTime(2026, 3),
      );
      final records = generateTaxRecords(config);
      for (final r in records) {
        expect(r.taxAmount, 0.0);
      }
    });

    test('月收入 10000，专项附加扣除 3000，税额相应减少', () {
      final config = QueryConfig(
        agent: '测试公司',
        monthlyIncome: 10000,
        specialDeduction: 3000,
        startMonth: DateTime(2026, 1),
        endMonth: DateTime(2026, 7),
      );
      final records = generateTaxRecords(config);

      // 每月应纳税所得额 = 10000 - 5000 - 3000 = 2000，税额 60
      for (final r in records) {
        expect(r.taxAmount, 60.0);
      }

      final total = records.fold<double>(0, (s, r) => s + r.taxAmount);
      expect(total, 420.0);
    });
  });
}
