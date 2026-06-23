VEHICLES = {
    "E-Loader": {
        "fuel": 1.23,
        "maintenance": 0.45
    },
    "Mini Truck": {
        "fuel": 5.0,
        "maintenance": 1.0
    },
    "Tata Ace": {
        "fuel": 7.36,
        "maintenance": 1.5
    },
    "14 ft Truck": {
        "fuel": 12.63,
        "maintenance": 2.25
    }
}


def calculate_price(vehicle, distance, load, route, time_type):

    base_cost = (
        VEHICLES[vehicle]["fuel"] +
        VEHICLES[vehicle]["maintenance"]
    )

    # Distance multiplier
    if distance <= 10:
        distance_multiplier = 1
    elif distance <= 25:
        distance_multiplier = 0.95
    else:
        distance_multiplier = 0.90

    # Load multiplier
    if load < 50:
        load_multiplier = 1
    elif load > 80:
        load_multiplier = 1.15
    else:
        load_multiplier = 1

    # Route multiplier
    route_multiplier = {
        "city": 1.10,
        "industrial": 1.05,
        "highway": 0.95
    }[route]

    # Time multiplier
    time_multiplier = {
        "normal": 1,
        "peak": 1.20,
        "night": 1.30,
        "weekend": 1.10
    }[time_type]

    adjusted_cost = (
        base_cost
        * distance_multiplier
        * load_multiplier
        * route_multiplier
        * time_multiplier
    )

    pickup_charge = 50 if distance <= 10 else 0

    trip_cost = (adjusted_cost * distance) + pickup_charge

    final_price = round(trip_cost * 1.15, 2)

    return {
        "base_cost": round(base_cost, 2),
        "distance_multiplier": distance_multiplier,
        "load_multiplier": load_multiplier,
        "route_multiplier": route_multiplier,
        "time_multiplier": time_multiplier,
        "pickup_charge": pickup_charge,
        "trip_cost": round(trip_cost, 2),
        "final_price": final_price
    }