import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reservation_system_customer/bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:reservation_system_customer/repository/data/reservation.dart';
import 'package:reservation_system_customer/ui/reservations/reservation_list_detail.dart';
import 'package:reservation_system_customer/ui/reservations/reservations_list_entry.dart';

import '../../app_localizations.dart';
import 'reservation_detail_page.dart';

class ReservationsListPage extends StatefulWidget {
  @override
  _ReservationsListPageState createState() => _ReservationsListPageState();
}

class _ReservationsListPageState extends State<ReservationsListPage> {
  final DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  List<Item> _data = new List();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReservationsBloc, ReservationsState>(
        builder: (context, state) {
      if (state is ReservationsInitial) {
        return Container();
      } else if (state is ReservationsLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is ReservationsLoaded) {
        updateList(state.reservations);
//        _data = generateItems(state.reservations);
        if (state.reservations.length > 0) {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Row(
                  children: <Widget>[
                    Container(
                      height: 40,
                      child: Image(
                          image: AssetImage("assets/005-calendar.png"),
                          fit: BoxFit.fitHeight),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            AppLocalizations.of(context)
                                .translate("reservations_title"),
                            style: TextStyle(color: Color(0xff322153)))),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                child: Container(
                  child: ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _data[index].isExpanded = !isExpanded;
                      });
                    },
                    children: _data.map<ExpansionPanel>((Item item) {
                      return ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return ReservationListEntry(item: item.reservation);
                        },
                        body: ReservationListDetail(
                          reservation: item.reservation,
                          resBloc: BlocProvider.of(context),
                        ),
                        isExpanded: item.isExpanded,
                      );
                    }).toList(),
                  ),
                ),
              ));
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  AppLocalizations.of(context).translate("no_reservations"),
                  style: Theme.of(context).textTheme.title,
                  textAlign: TextAlign.center,
                ),
              )
            ],
          );
        }
      }
      return Container();
    });
  }

  void updateList(List<Reservation> reservations) {
    reservations.forEach((res) => addIfNew(res));
  }

  void addIfNew(Reservation res) {
    bool isNew = true;
    if (_data == null) {
      _data.add(Item(reservation: res));
      return;
    }
    _data.forEach((item) => {if (item.reservation.id == res.id) isNew = false});
    if (isNew) _data.add(Item(reservation: res));
  }
}

class Item extends Equatable {
  final Reservation reservation;
  bool isExpanded;

  Item({
    this.reservation,
    this.isExpanded = false,
  });

  @override
  List<Object> get props => [reservation.id];
}
