/// 主页查询条件配置
class QueryConfig {
  final String agent; // 扣缴义务人
  final double monthlyIncome; // 每月收入
  final double specialDeduction; // 每月专项附加扣除（房租、子女教育等，可为 0）
  final DateTime startMonth; // 所属期起（只取年月）
  final DateTime endMonth; // 所属期止（只取年月）

  const QueryConfig({
    required this.agent,
    required this.monthlyIncome,
    this.specialDeduction = 0,
    required this.startMonth,
    required this.endMonth,
  });

  /// 区间内的月份数（含起止）
  int get monthCount =>
      (endMonth.year - startMonth.year) * 12 +
      endMonth.month -
      startMonth.month +
      1;
}

/// 单条收入纳税明细
class TaxRecord {
  final String month; // 所属期，如 "2026-07"
  final String agent; // 扣缴义务人
  final double income; // 收入
  final double taxAmount; // 已申报税额

  const TaxRecord({
    required this.month,
    required this.agent,
    required this.income,
    required this.taxAmount,
  });
}

/// 每月基本减除费用（起征点）
const double _monthlyDeduction = 5000.0;

/// 居民个人工资薪金累计预扣预缴税率表：(累计应纳税所得额上限, 预扣率, 速算扣除数)
const List<(double, double, double)> _taxBrackets = [
  (36000.0, 0.03, 0.0),
  (144000.0, 0.10, 2520.0),
  (300000.0, 0.20, 16920.0),
  (420000.0, 0.25, 31920.0),
  (660000.0, 0.30, 52920.0),
  (960000.0, 0.35, 85920.0),
  (double.infinity, 0.45, 181920.0),
];

/// 按累计预扣预缴法计算累计应纳税额
double _cumulativeTax(double cumulativeTaxable) {
  for (final (limit, rate, quickDeduction) in _taxBrackets) {
    if (cumulativeTaxable <= limit) {
      return cumulativeTaxable * rate - quickDeduction;
    }
  }
  return 0;
}

/// 按配置生成模拟明细，月份倒序（最新的在最上面）
///
/// 采用工资薪金累计预扣预缴法：
/// 累计应纳税所得额 = 累计收入 - 5000 × 月份数 - 累计专项附加扣除
/// 当月税额 = 累计应纳税额 - 累计已预扣预缴税额
List<TaxRecord> generateTaxRecords(QueryConfig config) {
  final records = <TaxRecord>[];
  var cumulativeTaxable = 0.0;
  var cumulativeTax = 0.0;
  for (var i = 0; i < config.monthCount; i++) {
    final d = DateTime(
      config.startMonth.year,
      config.startMonth.month + i,
    );
    final mm = d.month.toString().padLeft(2, '0');
    cumulativeTaxable +=
        config.monthlyIncome - _monthlyDeduction - config.specialDeduction;
    final newCumulativeTax =
        cumulativeTaxable <= 0 ? 0.0 : _cumulativeTax(cumulativeTaxable);
    final tax = (newCumulativeTax - cumulativeTax).clamp(0.0, double.infinity);
    cumulativeTax = newCumulativeTax;
    records.add(
      TaxRecord(
        month: '${d.year}-$mm',
        agent: config.agent,
        income: config.monthlyIncome,
        taxAmount: double.parse(tax.toStringAsFixed(2)),
      ),
    );
  }
  return records.reversed.toList();
}
