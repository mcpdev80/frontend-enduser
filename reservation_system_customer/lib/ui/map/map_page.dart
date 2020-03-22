import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reservation_system_customer/bloc/bloc.dart';
import 'package:reservation_system_customer/ui/map/map_view.dart';

import 'location_detail_sheet.dart';

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(builder: (context, state) {
      Map<MarkerId, Marker> markers = {};
      if (state is MapLocationsLoaded) {
        state.locations.forEach((location) {
          final id = '${location.id}';
          markers[MarkerId(id)] = Marker(
            markerId: MarkerId(id),
            position: location.position,
            icon: state.markerIcons[location.fillStatus],
            infoWindow: InfoWindow(
                title: location.name, snippet: "A Short description"),
            // TODO remove
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0))),
                builder: (context) => LocationDetailSheet(location: location),
              );
            },
          );
        });
      }
      return MapView(
        markers: markers,
      );
    });
  }
}
