// ignore_for_file: missing_return

import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:repair_service_ui/actions/api.dart';
import 'package:repair_service_ui/models/model.dart';
import 'package:repair_service_ui/pages/booking/show.dart';
import 'package:repair_service_ui/pages/setting/bluetooth/bluetooth.dart';
import 'package:repair_service_ui/utils/functions.dart';
import 'package:ticket_widget/ticket_widget.dart';

class Scanner extends StatefulWidget {
  const Scanner({Key key}) : super(key: key);

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> with SingleTickerProviderStateMixin {
  String barcode;

  MobileScannerController controller = MobileScannerController(
      torchEnabled: false, formats: [BarcodeFormat.qrCode]);

  bool isStarted = true;
  BookingModel booking;
  bool isLoading = false;
  final box = GetStorage();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: Text(
          'HAKIKI TIKETI',
        ),
        actions: [
          box.read('is_printer') == false
              ? InkWell(
                  onTap: () => Functions.pushPage(context, BluetoothSetting()),
                  child: Padding(
                      padding: EdgeInsets.all(12),
                      child: box.read('bluetooth_device_connected') != null
                          ? Icon(
                              Icons.bluetooth_connected_rounded,
                              color: Colors.white70,
                              size: 28,
                            )
                          : Icon(
                              Icons.bluetooth_disabled,
                              color: Colors.white70,
                              size: 28,
                            )),
                )
              : SizedBox()
        ],
      ),
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              isStarted == false
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            )
                          : renderTicket(booking))
                  : Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: MobileScanner(
                        controller: controller,
                        fit: BoxFit.cover,
                        onDetect: (barcode, args) async {
                          setState(() {
                            this.barcode = barcode.rawValue;
                            isLoading = true;
                            isStarted = false;
                            booking = null;
                          });
                          await getBooking();
                        },
                      )),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 80,
                  color: Colors.redAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        color: Colors.white,
                        icon: ValueListenableBuilder(
                          valueListenable: controller.torchState,
                          builder: (context, state, child) {
                            if (state == null) {
                              return Icon(
                                Icons.flash_off,
                                color: Colors.grey,
                              );
                            }
                            switch (state as TorchState) {
                              case TorchState.off:
                                return const Icon(
                                  Icons.flash_off,
                                  color: Colors.white,
                                );
                              case TorchState.on:
                                return const Icon(
                                  Icons.flash_on,
                                  color: Colors.yellow,
                                );
                            }
                          },
                        ),
                        iconSize: 32.0,
                        onPressed: () => controller.toggleTorch(),
                      ),
                      IconButton(
                          color: Colors.white,
                          icon: isStarted
                              ? const Icon(Icons.stop)
                              : const Icon(Icons.play_arrow),
                          iconSize: 32.0,
                          onPressed: () async {
                            setState(() {
                              isStarted = true;
                              barcode = null;
                              isLoading = false;
                              booking = null;
                            });
                            Functions.pushPageReplacement(context, this.widget);
                          }),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 200,
                          height: 35,
                          child: FittedBox(
                            child: Text(
                              barcode ?? 'Scan ',
                              overflow: TextOverflow.fade,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        color: Colors.white,
                        icon: ValueListenableBuilder(
                          valueListenable: controller.cameraFacingState,
                          builder: (context, state, child) {
                            if (state == null) {
                              return const Icon(Icons.camera_front);
                            }
                            switch (state as CameraFacing) {
                              case CameraFacing.front:
                                return const Icon(Icons.camera_front);
                              case CameraFacing.back:
                                return const Icon(Icons.camera_rear);
                            }
                          },
                        ),
                        iconSize: 32.0,
                        onPressed: () => controller.switchCamera(),
                      ),
                      IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.image),
                        iconSize: 32.0,
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          // Pick an image
                          final XFile image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            if (await controller.analyzeImage(image.path)) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tumepata barcode'),
                                  backgroundColor: Colors.black87,
                                ),
                              );
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Hakuna barcode imepatikana!'),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget renderTicket(BookingModel booking) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            margin: EdgeInsets.only(bottom: 40),
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 40),
            child: TicketWidget(
                width: 350,
                height: MediaQuery.of(context).size.height * 0.75,
                isCornerRounded: true,
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.all(10),
                child: booking == null
                    ? EmptyWidget(
                        title: 'Tafuta Tiketi',
                        titleTextStyle: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w600),
                        subTitle: 'Scan tiketi kuangalia uhalali',
                        hideBackgroundAnimation: true)
                    : BookingTicket(booking: booking))));
  }

  Future<BookingModel> getBooking() async {
    BookingModel data;
    if (barcode != null) {
      data = await Api.getBooking(barcode);
    }

    setState(() {
      booking = data;
      isLoading = !isLoading;
    });
  }
}
