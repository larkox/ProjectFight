pieces = [
    {
        "class": "piece",
        "attributes": {
            "type": "leg",
            "name": "Basic Legs",
            "movement": 5.0,
            "jump": 30.0,
            "weight": 5.0,
            "max_weight": 30.0,
            "power": 1.0,
            "base_points": [
                {"x":40, "y":10},
                {"x":40, "y":10},
                {"x":0, "y":0},
                {"x":0, "y":0},
                ],
        },
        "image": "src/images/pieces/0.png",
        "dimensions": [
            {"w": 80, "h": 80},
            {"w": 80, "h": 40},
            {"w": 40, "h": 40},
            {"w": 40, "h": 40},
            ],
        "frames": [2, 1, 1, 1]
    },
    {
        "class": "piece",
        "attributes": {
            "type": "body",
            "name": "Basic Body",
            "weight": 5.0,
            "defense": 1.0,
            "special_defense": 1.0,
            "hit_points": 100.0,
            "legs_points": [
                {"x":30, "y":60},
                {"x":30, "y":60},
                {"x":30, "y":60},
                {"x":0, "y":0},
                {"x":0, "y":0},
                ],
            "head_points": [
                {"x":40, "y":20},
                {"x":40, "y":20},
                {"x":40, "y":20},
                {"x":0, "y":0},
                {"x":0, "y":0},
                ],
            "arms_points": [
                {"x":50, "y":30},
                {"x":50, "y":30},
                {"x":50, "y":30},
                {"x":0, "y":0},
                {"x":0, "y":0},
                ],
        },
        "image": "src/images/pieces/1.png",
        "dimensions": [
            {"w": 80, "h": 80},
            {"w": 80, "h": 80},
            {"w": 80, "h": 80},
            {"w": 80, "h": 80},
            ],
        "frames": [1, 1, 1, 1]
    },
    {
        "class": "piece",
        "attributes": {
            "type": "head",
            "name": "Basic Head",
            "weight": 3.0,
            "special_power": 1.0,
            "base_points": [
                {"x":30, "y":80},
                {"x":30, "y":80},
                {"x":30, "y":80},
                {"x":0, "y":0},
                {"x":0, "y":0},
                ],
        },
        "image": "src/images/pieces/2.png",
        "dimensions": [
            {"w": 80, "h": 80},
            {"w": 80, "h": 80},
            {"w": 80, "h": 80},
            {"w": 80, "h": 80},
            ],
        "frames": [1, 1, 1, 1]
    },
    {
        "class": "piece",
        "attributes": {
            "type": "arm",
            "name": "Basic Arm",
            "weight": 5.0,
            "power": 1.0,
            "defense": 1.0,
            "base_points": [
                {"x":0, "y":40},
                {"x":0, "y":40},
                {"x":0, "y":40},
                {"x":0, "y":0},
                {"x":0, "y":0},
                ],
        },
        "image": "src/images/pieces/3.png",
        "dimensions": [
            {"w": 80, "h": 80},
            {"w": 80, "h": 80},
            {"w": 80, "h": 80},
            {"w": 80, "h": 80},
            ],
        "frames": [1, 1, 1, 1]
    }
]
