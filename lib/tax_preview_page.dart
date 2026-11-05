import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'tax_list_page.dart';

/// 预览页：逐月修改收入和已申报税额，确认后进入纳税明细页
class TaxPreviewPage extends StatefulWidget {
  final List<TaxRecord> records;

  /// 是否用计算出的税额预填；false 则税额预填 0，由用户手填
  final bool autoCalcTax;

  const TaxPreviewPage({
    super.key,
    required this.records,
    this.autoCalcTax = true,
  });

  @override
  State<TaxPreviewPage> createState() => _TaxPreviewPageState();
}

class _TaxPreviewPageState extends State<TaxPreviewPage> {
  late final List<TextEditingController> _incomeControllers;
  late final List<TextEditingController> _taxControllers;

  @override
  void initState() {
    super.initState();
    _incomeControllers = widget.records
        .map((r) => TextEditingController(text: r.income.toStringAsFixed(2)))
        .toList();
    _taxControllers = widget.records
        .map(
          (r) => TextEditingController(
            text: widget.autoCalcTax ? r.taxAmount.toStringAsFixed(2) : '0.00',
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final c in _incomeControllers) {
      c.dispose();
    }
    for (final c in _taxControllers) {
      c.dispose();
    }
    super.dispose();
  }

  double get _totalIncome {
    var total = 0.0;
    for (final c in _incomeControllers) {
      total += double.tryParse(c.text.trim()) ?? 0;
    }
    return total;
  }

  double get _totalTax {
    var total = 0.0;
    for (final c in _taxControllers) {
      total += double.tryParse(c.text.trim()) ?? 0;
    }
    return total;
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  /// 校验并收集修改后的明细，非法输入返回 null
  List<TaxRecord>? _collectRecords() {
    final result = <TaxRecord>[];
    for (var i = 0; i < widget.records.length; i++) {
      final income = double.tryParse(_incomeControllers[i].text.trim());
      if (income == null || income < 0) {
        _showToast('第 ${i + 1} 条收入格式不正确');
        return null;
      }
      final tax = double.tryParse(_taxControllers[i].text.trim());
      if (tax == null || tax < 0) {
        _showToast('第 ${i + 1} 条税额格式不正确');
        return null;
      }
      final r = widget.records[i];
      result.add(
        TaxRecord(
          month: r.month,
          agent: r.agent,
          income: income,
          taxAmount: tax,
        ),
      );
    }
    return result;
  }

  void _goDetail() {
    final updated = _collectRecords();
    if (updated == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaxListPage(records: updated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "收入明细预览",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black.withValues(alpha: 0.8),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Color(0xffF6F5FA),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "收入合计:",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${_totalIncome.toStringAsFixed(2)}元",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: double.infinity,
                  color: Colors.black.withValues(alpha: 0.1),
                ),
                Row(
                  children: [
                    Text(
                      "已申报税额合计:",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${_totalTax.toStringAsFixed(2)}元",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                spacing: 10,
                children: List.generate(widget.records.length, (i) {
                  return _buildMonthEditor(i);
                }),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 14),
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xff4A84E3),
                onPressed: _goDetail,
                child: const Text(
                  "查看纳税明细",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthEditor(int index) {
    final record = widget.records[index];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            record.month,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            "扣缴义务人：${record.agent}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.4),
              fontWeight: FontWeight.w400,
            ),
          ),
          _divider(),
          _buildInputRow(
            label: "收入",
            controller: _incomeControllers[index],
          ),
          _buildInputRow(
            label: "已申报税额",
            controller: _taxControllers[index],
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (_) => setState(() {}),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 14, color: Colors.black),
              decoration: InputDecoration(
                hintText: "请输入金额",
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xffB4B4B4),
                ),
                border: InputBorder.none,
                isDense: true,
                suffixText: "元",
                suffixStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: double.infinity,
      color: Colors.black.withValues(alpha: 0.08),
    );
  }
}
