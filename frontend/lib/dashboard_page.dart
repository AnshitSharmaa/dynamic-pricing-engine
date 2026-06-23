import 'package:flutter/material.dart';
import 'location_service.dart';
import 'route_service.dart';
import 'api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final pickupController = TextEditingController();
  final dropController = TextEditingController();
  final loadController = TextEditingController();

  String selectedVehicle = 'Tata Ace';

  double? calculatedDistance;
  Map<String, dynamic>? pricing;
  double? durationMinutes;
  String routeType = "--";
  String timeType = "--";

  bool isLoading = false;

  Future<void> calculatePricing() async {
    try {
      setState(() {
        isLoading = true;
      });

      final pickup = await LocationService.getCoordinates(
        pickupController.text,
      );

      final drop = await LocationService.getCoordinates(dropController.text);

      if (pickup == null || drop == null) {
        throw Exception("Location not found");
      }

      final routeData = await RouteService.getRoute(
        startLat: pickup['lat']!,
        startLon: pickup['lon']!,
        endLat: drop['lat']!,
        endLon: drop['lon']!,
      );

      if (routeData == null) {
        throw Exception("Could not calculate route");
      }

      final distance = routeData["distance"];
      final duration = routeData["duration"];

      final load = double.tryParse(loadController.text.trim()) ?? 0;
      final now = DateTime.now();

      String detectedTimeType = "normal";

      if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
        detectedTimeType = "weekend";
      } else if (now.hour >= 22 || now.hour < 6) {
        detectedTimeType = "night";
      } else if ((now.hour >= 7 && now.hour <= 10) ||
          (now.hour >= 17 && now.hour <= 21)) {
        detectedTimeType = "peak";
      }

      String detectedRouteType = "city";

      if (distance > 30) {
        detectedRouteType = "highway";
      } else if (distance > 10) {
        detectedRouteType = "industrial";
      }
      final pricingData = await ApiService.calculatePrice(
        vehicle: selectedVehicle,
        distance: distance,
        load: load,
      );

      setState(() {
        calculatedDistance = distance;
        durationMinutes = duration;
        pricing = pricingData;

        routeType = detectedRouteType;
        timeType = detectedTimeType;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '🚚 Dynamic Pricing Engine',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;

          if (isDesktop) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildInputPanel()),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(child: _buildResultPanel()),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInputPanel(),
                const SizedBox(height: 20),
                _buildResultPanel(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputPanel() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Trip Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: pickupController,
              decoration: InputDecoration(
                labelText: "Pickup Location",
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: dropController,
              decoration: InputDecoration(
                labelText: "Drop Location",
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedVehicle,
              items: const [
                DropdownMenuItem(value: 'E-Loader', child: Text('E-Loader')),
                DropdownMenuItem(
                  value: 'Mini Truck',
                  child: Text('Mini Truck'),
                ),
                DropdownMenuItem(value: 'Tata Ace', child: Text('Tata Ace')),
                DropdownMenuItem(
                  value: '14 ft Truck',
                  child: Text('14 ft Truck'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedVehicle = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Vehicle Type",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: loadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Load Percentage",
                prefixIcon: const Icon(Icons.inventory),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : calculatePricing,
                icon: const Icon(Icons.calculate),
                label: Text(
                  isLoading ? "Calculating..." : "Calculate Price",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPanel() {
    return Column(
      children: [
        Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Text(
                  "Estimated Price",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text(
                  pricing == null ? "--" : "₹${pricing!['final_price']}",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        if (pricing != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pricing Breakdown",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Text("Base Cost: ₹${pricing!['base_cost']}"),
                  Text("Distance Factor: ${pricing!['distance_multiplier']}x"),
                  Text("Load Factor: ${pricing!['load_multiplier']}x"),
                  Text("Route Factor: ${pricing!['route_multiplier']}x"),
                  Text("Time Factor: ${pricing!['time_multiplier']}x"),
                  Text("Pickup Charge: ₹${pricing!['pickup_charge']}"),
                  Text("Trip Cost: ₹${pricing!['trip_cost']}"),
                ],
              ),
            ),
          ),
        _infoCard(
          "Distance",
          calculatedDistance == null
              ? "--"
              : "${calculatedDistance!.toStringAsFixed(2)} km",
          Icons.route,
        ),
        _infoCard(
          "ETA",
          durationMinutes == null
              ? "--"
              : "${durationMinutes!.toStringAsFixed(0)} mins",
          Icons.access_time,
        ),
        _infoCard("Route Type", routeType, Icons.map),

        _infoCard("Surge Type", timeType, Icons.bolt),
        _infoCard("Vehicle", selectedVehicle, Icons.local_shipping),

        _infoCard(
          "Pickup",
          pickupController.text.isEmpty ? "--" : pickupController.text,
          Icons.location_on,
        ),

        _infoCard(
          "Drop",
          dropController.text.isEmpty ? "--" : dropController.text,
          Icons.flag,
        ),

        _infoCard(
          "Load",
          loadController.text.isEmpty ? "--" : "${loadController.text}%",
          Icons.inventory,
        ),
      ],
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
