import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'tax_preview_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _agentController = TextEditingController();
  final _incomeController = TextEditingController();
  final _deductionController = TextEditingController();
  DateTime _startMonth = DateTime(2026, 1);
  DateTime _endMonth = DateTime(2026, 7);
  bool _autoCalcTax = true;

  @override
  void dispose() {
    _agentController.dispose();
    _incomeController.dispose();
    _deductionController.dispose();
    super.dispose();
  }

  String _formatMonth(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  double? get _income => double.tryParse(_incomeController.text.trim());

  /// 专项附加扣除，未填默认 0
  double get _deduction {
    final text = _deductionController.text.trim();
    if (text.isEmpty) return 0;
    final value = double.tryParse(text);
    return value == null || value < 0 ? 0 : value;
  }

  int get _monthCount =>
      (_endMonth.year - _startMonth.year) * 12 +
      _endMonth.month -
      _startMonth.month +
      1;

  Future<void> _pickMonth({required bool isStart}) async {
    final initial = isStart ? _startMonth : _endMonth;
    DateTime temp = initial;
    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xff999999),
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      '确定',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xff4A84E3),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.monthYear,
                  initialDateTime: initial,
                  minimumYear: 2000,
                  maximumYear: 2100,
                  onDateTimeChanged: (d) => temp = d,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      if (isStart) {
        _startMonth = DateTime(temp.year, temp.month);
        if (_endMonth.isBefore(_startMonth)) {
          _endMonth = _startMonth;
        }
      } else {
        _endMonth = DateTime(temp.year, temp.month);
        if (_endMonth.isBefore(_startMonth)) {
          _startMonth = _endMonth;
        }
      }
    });
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _query() {
    final agent = _agentController.text.trim();
    final income = _income;
    if (agent.isEmpty) {
      _showToast('请输入扣缴义务人');
      return;
    }
    if (income == null || income <= 0) {
      _showToast('请输入正确的每月收入');
      return;
    }
    final config = QueryConfig(
      agent: agent,
      monthlyIncome: income,
      specialDeduction: _deduction,
      startMonth: DateTime(_startMonth.year, _startMonth.month),
      endMonth: DateTime(_endMonth.year, _endMonth.month),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaxPreviewPage(
          records: generateTaxRecords(config),
          autoCalcTax: _autoCalcTax,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final income = _income;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "个税模拟器",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildField(
                    label: "扣缴义务人",
                    child: Expanded(
                      child: TextField(
                        controller: _agentController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          hintText: "请输入公司名称",
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xffB4B4B4),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  _divider(),
                  _buildField(
                    label: "每月收入",
                    child: Expanded(
                      child: TextField(
                        controller: _incomeController,
                        onChanged: (_) => setState(() {}),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          hintText: "请输入金额",
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xffB4B4B4),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    suffix: Text(
                      "元",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  _divider(),
                  _buildField(
                    label: "专项附加扣除",
                    child: Expanded(
                      child: TextField(
                        controller: _deductionController,
                        onChanged: (_) => setState(() {}),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          hintText: "如房租、子女教育等（选填）",
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xffB4B4B4),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    suffix: Text(
                      "元",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  _divider(),
                  _buildField(
                    label: "所属期起",
                    child: Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _pickMonth(isStart: true),
                        child: Text(
                          _formatMonth(_startMonth),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xff4A84E3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _divider(),
                  _buildField(
                    label: "所属期止",
                    child: Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _pickMonth(isStart: false),
                        child: Text(
                          _formatMonth(_endMonth),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xff4A84E3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _divider(),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "默认计算申报税",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        CupertinoSwitch(
                          value: _autoCalcTax,
                          activeTrackColor: const Color(0xff4A84E3),
                          onChanged: (v) => setState(() => _autoCalcTax = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "共 $_monthCount 个月",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                  Text(
                    income != null && income > 0
                        ? "预计总收入 ${(income * _monthCount).toStringAsFixed(2)} 元"
                        : "预计总收入 -- 元",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 14),
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xff4A84E3),
              onPressed: _query,
              child: const Text(
                "查  询",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 0.5,
      width: double.infinity,
      color: Colors.black.withValues(alpha: 0.08),
    );
  }

  Widget _buildField({
    required String label,
    required Widget child,
    Widget? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),
          ),
          child,
          if (suffix != null) ...[
            const SizedBox(width: 4),
            suffix,
          ],
        ],
      ),
    );
  }
}
