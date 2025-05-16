import 'dart:io';
import 'dart:typed_data';
import 'package:ecinema_desktop/models/booking_concession.dart';
import 'package:ecinema_desktop/models/concession.dart';
import 'package:ecinema_desktop/models/month_data.dart';
import 'package:ecinema_desktop/models/ticket.dart';
import 'package:ecinema_desktop/providers/booking_concession_provider.dart';
import 'package:ecinema_desktop/providers/concession_provider.dart';
import 'package:ecinema_desktop/providers/ticket_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';
import 'package:file_picker/file_picker.dart';

enum ReportType { Tickets, Concessions }

class TicketReportPage extends StatefulWidget {
  @override
  _TicketReportPageState createState() => _TicketReportPageState();
}

class _TicketReportPageState extends State<TicketReportPage> {
  final List<int> _ranges = [1, 3, 6];
  int _selectedRange = 3;
  ReportType _selectedType = ReportType.Tickets;

  late Future<List<Ticket>> _ticketsFut;
  late Future<List<BookingConcession>> _concsFut;
  late Future<List<Concession>> _concTypesFut;

  final _ticketCountChartController = ScreenshotController();
  final _ticketRevenueChartController = ScreenshotController();
  final _concessionNameChartController = ScreenshotController();
  final _concessionRevenueChartController = ScreenshotController();

  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _ticketsFut = TicketProvider().get().then((r) => r.result as List<Ticket>);
    _concsFut = BookingConcessionProvider().get().then(
      (r) => r.result as List<BookingConcession>,
    );
    _concTypesFut = ConcessionProvider().get().then(
      (r) => r.result as List<Concession>,
    );
  }

  DateTime get _now => DateTime.now();
  DateTime get _earliest =>
      DateTime(_now.year, _now.month - _selectedRange + 1, 1);
  DateTime get _firstOfNextMonth => DateTime(_now.year, _now.month + 1, 1);

  Future<List<MonthData>> _prepareTicketData() async {
    final tickets = await _ticketsFut;
    final map = <String, List<Ticket>>{};
    for (var t in tickets) {
      if (t.bookingTime.isBefore(_earliest) ||
          !t.bookingTime.isBefore(_firstOfNextMonth))
        continue;
      final key = DateFormat('yyyy-MM').format(t.bookingTime);
      map.putIfAbsent(key, () => []).add(t);
    }
    final keys = map.keys.toList()..sort();
    return keys.map((k) {
      final list = map[k]!;
      final date = DateFormat('yyyy-MM').parse(k);
      final count = list.length;
      final sum = list.fold<double>(0, (s, t) => s + t.price.toDouble());
      return MonthData(month: date, ticketCount: count, revenue: sum);
    }).toList();
  }

  Future<List<_ChartPoint>> _prepareConcessionNameData() async {
    final concs = await _concsFut;
    final types = await _concTypesFut;
    final counter = <int, int>{};
    for (var c in concs) {
      if (c.bookingTime.isBefore(_earliest) ||
          !c.bookingTime.isBefore(_firstOfNextMonth))
        continue;
      counter.update(
        c.concessionId,
        (v) => v + c.quantity,
        ifAbsent: () => c.quantity,
      );
    }
    if (types.isEmpty && counter.isNotEmpty) {
      print("Warning: Concession types might not be loaded yet for names.");
      return [];
    }
    return counter.entries.map((e) {
      final type = types.firstWhere(
        (t) => t.id == e.key,
        orElse: () {
          print(
            "Warning: Concession type with ID ${e.key} not found. Using 'Unknown'.",
          );
          return Concession(e.key, 'Unknown (ID: ${e.key})', 0.0, '');
        },
      );

      return _ChartPoint(type.name ?? 'Unnamed', e.value.toDouble());
    }).toList();
  }

  Future<List<MonthData>> _prepareConcessionMonthlyRevenue() async {
    final concs = await _concsFut;
    final map = <String, double>{};
    for (var c in concs) {
      if (c.bookingTime.isBefore(_earliest) ||
          !c.bookingTime.isBefore(_firstOfNextMonth))
        continue;
      final key = DateFormat('yyyy-MM').format(c.bookingTime);
      final sum = c.unitPrice.toDouble() * c.quantity;
      map[key] = (map[key] ?? 0) + sum;
    }
    final keys = map.keys.toList()..sort();
    return keys.map((k) {
      final date = DateFormat('yyyy-MM').parse(k);
      return MonthData(month: date, ticketCount: 0, revenue: map[k]!);
    }).toList();
  }

  Future<void> _exportToPdf() async {
    if (!mounted) return;
    setState(() => _isExporting = true);

    final pdf = pw.Document();
    final String reportTypeString =
        _selectedType == ReportType.Tickets ? "Tickets" : "Concessions";
    final String rangeString =
        "$_selectedRange month${_selectedRange > 1 ? 's' : ''}";
    final String timestamp = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(DateTime.now());

    final double pdfChartHeight = 200.0 * (72.0 / 96.0);

    final double capturePixelRatio = 1.5;

    List<pw.Widget> pdfWidgets = [];

    if (_selectedType == ReportType.Tickets) {
      final List<MonthData> ticketData = await _prepareTicketData();
      if (ticketData.isNotEmpty) {
        try {
          final imageTicketCount = await _ticketCountChartController.capture(
            pixelRatio: capturePixelRatio,
          );
          if (imageTicketCount != null) {
            pdfWidgets.add(
              pw.Text(
                'Sold Tickets',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
            pdfWidgets.add(pw.SizedBox(height: 8));
            pdfWidgets.add(
              pw.Image(
                pw.MemoryImage(imageTicketCount),
                height: pdfChartHeight,
                fit: pw.BoxFit.contain,
              ),
            );
            pdfWidgets.add(pw.SizedBox(height: 16));
          }
        } catch (e) {
          print("Error capturing ticket count chart: $e");
          pdfWidgets.add(
            pw.Text(
              'Error capturing Sold Tickets chart.',
              style: pw.TextStyle(color: PdfColors.red),
            ),
          );
        }

        try {
          final imageTicketRevenue = await _ticketRevenueChartController
              .capture(pixelRatio: capturePixelRatio);
          if (imageTicketRevenue != null) {
            pdfWidgets.add(
              pw.Text(
                'Ticket Revenue',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
            pdfWidgets.add(pw.SizedBox(height: 8));
            pdfWidgets.add(
              pw.Image(
                pw.MemoryImage(imageTicketRevenue),
                height: pdfChartHeight,
                fit: pw.BoxFit.contain,
              ),
            );
            pdfWidgets.add(pw.SizedBox(height: 16));
          }
        } catch (e) {
          print("Error capturing ticket revenue chart: $e");
          pdfWidgets.add(
            pw.Text(
              'Error capturing Ticket Revenue chart.',
              style: pw.TextStyle(color: PdfColors.red),
            ),
          );
        }
      } else {
        pdfWidgets.add(
          pw.Center(
            child: pw.Text(
              'No ticket data available for the selected range.',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          ),
        );
      }
    } else {
      final List<_ChartPoint> concessionNameData =
          await _prepareConcessionNameData();
      if (concessionNameData.isNotEmpty) {
        try {
          final imageNameChart = await _concessionNameChartController.capture(
            pixelRatio: capturePixelRatio,
          );
          if (imageNameChart != null) {
            pdfWidgets.add(
              pw.Text(
                'Concessions (by item count)',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
            pdfWidgets.add(pw.SizedBox(height: 8));
            pdfWidgets.add(
              pw.Image(
                pw.MemoryImage(imageNameChart),
                height: pdfChartHeight,
                fit: pw.BoxFit.contain,
              ),
            );
            pdfWidgets.add(pw.SizedBox(height: 16));
          }
        } catch (e) {
          print("Error capturing concession name chart: $e");
          pdfWidgets.add(
            pw.Text(
              'Error capturing Concessions by item chart.',
              style: pw.TextStyle(color: PdfColors.red),
            ),
          );
        }
      } else {
        pdfWidgets.add(
          pw.Center(
            child: pw.Text(
              'No concession item data available for the selected range.',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          ),
        );
      }
      pdfWidgets.add(pw.SizedBox(height: 16));

      final List<MonthData> concessionMonthlyRevenue =
          await _prepareConcessionMonthlyRevenue();
      if (concessionMonthlyRevenue.isNotEmpty) {
        try {
          final imageConcessionRevenue = await _concessionRevenueChartController
              .capture(pixelRatio: capturePixelRatio);
          if (imageConcessionRevenue != null) {
            pdfWidgets.add(
              pw.Text(
                'Concession Revenue (monthly)',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
            pdfWidgets.add(pw.SizedBox(height: 8));
            pdfWidgets.add(
              pw.Image(
                pw.MemoryImage(imageConcessionRevenue),
                height: pdfChartHeight,
                fit: pw.BoxFit.contain,
              ),
            );
            pdfWidgets.add(pw.SizedBox(height: 16));
          }
        } catch (e) {
          print("Error capturing concession revenue chart: $e");
          pdfWidgets.add(
            pw.Text(
              'Error capturing Concession Revenue chart.',
              style: pw.TextStyle(color: PdfColors.red),
            ),
          );
        }
      } else {
        pdfWidgets.add(
          pw.Center(
            child: pw.Text(
              'No concession revenue data available for the selected range.',
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),
          ),
        );
      }
    }

    if (pdfWidgets.whereType<pw.Image>().isEmpty && pdfWidgets.isNotEmpty) {
      pdfWidgets.add(pw.SizedBox(height: 20));
      pdfWidgets.add(
        pw.Center(
          child: pw.Text(
            "No charts were generated for this report.",
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerLeft,
            margin: const pw.EdgeInsets.only(bottom: 10.0),
            child: pw.Text(
              'eCinema Report: $reportTypeString - Last $rangeString (Generated: $timestamp)',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
          );
        },
        build: (pw.Context context) {
          return pdfWidgets;
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10.0),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.Theme.of(
                context,
              ).defaultTextStyle.copyWith(color: PdfColors.grey),
            ),
          );
        },
      ),
    );

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF Report',
      fileName:
          'ecinema_report_${_selectedType.name.toLowerCase()}_${_selectedRange}m_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (outputFile != null) {
      final file = File(outputFile);
      try {
        await file.writeAsBytes(await pdf.save());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF Exported successfully to $outputFile')),
          );
        }
      } catch (e) {
        print("Error saving PDF: $e");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving PDF: $e')));
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF Export cancelled')));
      }
    }

    if (mounted) {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectors = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        DropdownButton<ReportType>(
          value: _selectedType,
          items:
              ReportType.values.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t == ReportType.Tickets ? 'Karte' : 'Hrana/Piće'),
                );
              }).toList(),
          onChanged: (v) {
            if (v != null && !_isExporting) setState(() => _selectedType = v);
          },
        ),
        SizedBox(width: 16),
        DropdownButton<int>(
          value: _selectedRange,
          items:
              _ranges.map((r) {
                return DropdownMenuItem(
                  value: r,
                  child: Text(' $r mjesec${r > 1 ? 'a' : ''}'),
                );
              }).toList(),
          onChanged: (v) {
            if (v != null && !_isExporting) setState(() => _selectedRange = v);
          },
        ),
      ],
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            selectors,
            SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.picture_as_pdf),
              label: Text("Export PDF"),
              onPressed: _isExporting ? null : _exportToPdf,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            if (_isExporting)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text("Generating PDF..."),
                  ],
                ),
              ),
            SizedBox(height: 8),
            Expanded(
              child:
                  _selectedType == ReportType.Tickets
                      ? FutureBuilder<List<MonthData>>(
                        future: _prepareTicketData(),
                        builder: (ctx, snap) {
                          if (snap.connectionState == ConnectionState.waiting &&
                              !snap.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snap.hasError) {
                            return Center(
                              child: Text(
                                "Error loading ticket data: ${snap.error}",
                              ),
                            );
                          }
                          if (!snap.hasData || snap.data!.isEmpty) {
                            return Center(
                              child: Text(
                                "No ticket data available for the selected period.",
                              ),
                            );
                          }
                          final data = snap.data!;
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Prodane karte',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Screenshot(
                                  controller: _ticketCountChartController,
                                  child: Container(
                                    color: Theme.of(context).cardColor,
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 200,
                                      child: _buildBarChart(
                                        data,
                                        (md) => md.ticketCount.toDouble(),
                                        labelFn:
                                            (md) => md.ticketCount.toString(),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 32),
                                Text(
                                  'Prihod od karata',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Screenshot(
                                  controller: _ticketRevenueChartController,
                                  child: Container(
                                    color: Theme.of(context).cardColor,
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 200,
                                      child: _buildBarChart(
                                        data,
                                        (md) => md.revenue,
                                        labelFn:
                                            (md) =>
                                                '${md.revenue.toStringAsFixed(0)} BAM',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                      : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FutureBuilder<List<_ChartPoint>>(
                              future: _prepareConcessionNameData(),
                              builder: (ctx, snap) {
                                if (snap.connectionState ==
                                        ConnectionState.waiting &&
                                    !snap.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snap.hasError) {
                                  return Center(
                                    child: Text(
                                      "Error loading concession data: ${snap.error}",
                                    ),
                                  );
                                }
                                if (!snap.hasData || snap.data!.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "No concession data available for the selected period.",
                                    ),
                                  );
                                }
                                final pts = snap.data!;
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Hrana/Piće (po količini)',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                    ),
                                    Screenshot(
                                      controller:
                                          _concessionNameChartController,
                                      child: Container(
                                        color: Theme.of(context).cardColor,
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          height: 200,
                                          child: _buildNameChart(
                                            pts,
                                            labelFn:
                                                (p) => p.y.toInt().toString(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: 32),
                            FutureBuilder<List<MonthData>>(
                              future: _prepareConcessionMonthlyRevenue(),
                              builder: (ctx, snap) {
                                if (snap.connectionState ==
                                        ConnectionState.waiting &&
                                    !snap.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snap.hasError) {
                                  return Center(
                                    child: Text(
                                      "Error loading concession revenue: ${snap.error}",
                                    ),
                                  );
                                }
                                if (!snap.hasData || snap.data!.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "No concession revenue data available for the selected period.",
                                    ),
                                  );
                                }
                                final data = snap.data!;
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Prihod od hrane/pića',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                    ),
                                    Screenshot(
                                      controller:
                                          _concessionRevenueChartController,
                                      child: Container(
                                        color: Theme.of(context).cardColor,
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          height: 200,
                                          child: _buildBarChart(
                                            data,
                                            (md) => md.revenue,
                                            labelFn:
                                                (md) =>
                                                    '${md.revenue.toStringAsFixed(0)} BAM',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(
    List<MonthData> data,
    double Function(MonthData) valueFn, {
    required String Function(MonthData) labelFn,
  }) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= data.length) return SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    DateFormat('MMM').format(data[i].month),
                    style: TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 20,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _calculateInterval(data.map(valueFn).toList()),
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(data.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: valueFn(data[i]),
                width: 20,
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).primaryColor,
              ),
            ],
            showingTooltipIndicators: [0],
          );
        }),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(data.map(valueFn).toList()),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, __) {
              final md = data[group.x.toInt()];
              return BarTooltipItem(
                '${DateFormat('MMM yyyy').format(md.month)}\n${labelFn(md)}',
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNameChart(
    List<_ChartPoint> points, {
    required String Function(_ChartPoint) labelFn,
  }) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 60,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= points.length) return SizedBox();
                return SideTitleWidget(
                  space: 4,
                  meta: meta,
                  child: Text(
                    points[i].x,
                    style: TextStyle(fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _calculateInterval(points.map((p) => p.y).toList()),
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(points.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: points[i].y,
                width: 20,
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
            showingTooltipIndicators: [0],
          );
        }),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(
            points.map((p) => p.y).toList(),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, __) {
              final p = points[group.x.toInt()];
              return BarTooltipItem(
                '${p.x}\n${labelFn(p)}',
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
      ),
    );
  }

  double? _calculateInterval(List<double> values) {
    if (values.isEmpty) return null;
    double maxVal = values.fold(0.0, (max, v) => v > max ? v : max);
    if (maxVal == 0) return 1;

    if (maxVal <= 10) return 1;
    if (maxVal <= 50) return 5;
    if (maxVal <= 100) return 10;
    if (maxVal <= 500) return 50;
    if (maxVal <= 1000) return 100;
    if (maxVal <= 5000) return 500;
    if (maxVal <= 10000) return 1000;
    return (maxVal / 5).ceilToDouble();
  }
}

class _ChartPoint {
  final String x;
  final double y;
  _ChartPoint(this.x, this.y);
}
