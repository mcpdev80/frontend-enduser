import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reservation_system_customer/bloc/bloc.dart';
import 'package:reservation_system_customer/repository/repository.dart';
import 'package:reservation_system_customer/ui/map/reservation_slot_selection.dart';
import 'reservation_confirmation_dialog.dart';

class LocationDetailSheet extends StatefulWidget {
  final Location location;

  LocationDetailSheet({
    Key key,
    @required this.location,
  }) : super(key: key);

  @override
  _LocationDetailSheetState createState() => _LocationDetailSheetState();
}

class _LocationDetailSheetState extends State<LocationDetailSheet> {
  DateTime barplotDate = DateTime.now();
  DateTime selectedTime;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    widget.location.name,
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
              ],
            ),
            ReservationSlotSelection(
              capacity_utilization: widget.location.capacity_utilization,
              barplotDate: barplotDate,
              selectedSlotChanged: (slot) {
                selectedTime = slot;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                FlatButton(
                  textColor: Theme.of(context).accentColor,
                  onPressed: () async {
                    Future<DateTime> selectedDate = showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(hours: 1)),
                      lastDate: DateTime.now().add(Duration(days: 2)),
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData.dark(),
                          child: child,
                        );
                      },
                    );
                    DateTime timepoint = await selectedDate;
                    setState(() {
                      if (timepoint != null &&
                          timepoint.isAfter(DateTime.now())) {
                        setState(() {
                          barplotDate = timepoint;
                        });
                      }
                    });
                  },
                  child: Text("Anderes Datum auswählen",
                      style: Theme.of(context).textTheme.caption),
                )
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: RaisedButton(
                  child: Text("Slot reservieren"),
                  onPressed: () {
                    debugPrint("Button pressed");
                    BlocProvider.of<ReservationsBloc>(context)
                        .add(MakeReservation(
                      locationId: widget.location.id,
                      startTime: selectedTime,
                    ));
                    debugPrint("Make Reservation finished");
                    return BlocBuilder<ReservationsBloc, ReservationsState>(
                        builder: (context, state) {
                          debugPrint("In bloc builder");
                          if (state is ReservationsInitial) {
                            return Container();
                          }
                          else if (state is ReservationsLoading) {
                            debugPrint("ReservationsLoading");
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          else if (state is ReservationsLoaded) {
                            if (state.error) {
                              debugPrint("Snackbar should show up");
                              return SnackBar(
                                content: Text("Error"),
                              );
                            }
                            else {
                              debugPrint("AlertDialog should show up");
                              var name = widget.location.name;
                              var startTime = selectedTime;
                              final DateFormat dateFormat = DateFormat("dd.MM.yyyy");
                              final DateFormat timeFormat = DateFormat("hh:mm");
                              return AlertDialog(
                                //title: Text('Reservation successful'),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text('Reservation successfull'),
                                    ),
                                    Icon(Icons.check),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text('Du hast am ${dateFormat.format(startTime)} um ${timeFormat.format(startTime)} einen Shopping-Slot bei ${name} reserviert.'),
                                  ],
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK'),
                                  )
                                ],
                              );
                            }
                          }
                          return Container();
                        }

                    );
                  },
                ),
              ),
            )
          ]),
    );
  }
}
