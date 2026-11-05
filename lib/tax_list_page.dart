import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'models.dart';

class TaxListPage extends StatefulWidget {
  final List<TaxRecord> records;
  const TaxListPage({super.key, required this.records});

  @override
  State<TaxListPage> createState() => _TaxListPageState();
}

class _TaxListPageState extends State<TaxListPage> {
  @override
  Widget build(BuildContext context) {
    final totalIncome = widget.records.fold<double>(0, (s, r) => s + r.income);
    final totalTax = widget.records.fold<double>(0, (s, r) => s + r.taxAmount);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "收入纳税明细",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black.withValues(alpha: 0.8),
          ),
        ),
        scrolledUnderElevation: 0,
        leadingWidth: 90,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Row(
            children: [
              const SizedBox(width: 16),
              SvgPicture.asset(
                'assets/images/back.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(Color(0xff4A84E3), BlendMode.srcIn),
              ),
              Text(
                '返回',
                style: TextStyle(fontSize: 16, color: Color(0xff4A84E3)),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              "批量申诉",
              style: TextStyle(fontSize: 16, color: Color(0xff4A84E3)),
            ),
          ),
        ],
        backgroundColor: Colors.white,
      ),
      backgroundColor: Color(0xffF6F5FA),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "收入合计",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 4,),
                    SvgPicture.asset(
                      'assets/images/1.svg',
                      width: 16,
                      height: 16,

                    ),
                    Text(
                      ":",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${totalIncome.toStringAsFixed(2)}元",
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
                  margin: EdgeInsets.symmetric(vertical: 8),
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
                      "${totalTax.toStringAsFixed(2)}元",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: SingleChildScrollView(
            child: Column(
              spacing: 10,
              children: widget.records
                  .map((record) => _TaxItem(record: record))
                  .toList(),
            ),
          ))
        ],
      ),
    );
  }
}

class _TaxItem extends StatelessWidget {
  final TaxRecord record;
  const _TaxItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {


    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 14),
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "工资薪金",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Text(
                record.month,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          Text(
            "所得项目小类：正常工资薪金",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.4),
              fontWeight: FontWeight.w400,
            ),
          ),
          Row(
            children: [
              Expanded(child: Text(
                "扣缴义务人：${record.agent}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w400,
                ),
              ),),
              const SizedBox(width: 60),
              Icon(Icons.arrow_forward_ios,color: Color(0xffC8C8C8),size: 20,)
            ],
          ),
          Text(
            "收入：${record.income.toStringAsFixed(2)}元",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.4),
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            "已申报税额：${record.taxAmount.toStringAsFixed(2)}元",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.4),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

