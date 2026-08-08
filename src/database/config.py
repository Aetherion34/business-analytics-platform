from pathlib import Path
PROCESSED_DIR = Path(__file__).resolve().parents[2] / "data" / "processed"
TABLE_CONFIGS = {
    "customers": {
        "file": PROCESSED_DIR / "customers_list.csv",
        "columns": {
            "customer_id": "customer_id",
            "customer_unique_id": "customer_unique_id",
            "customer_zip_code_prefix": "zip_code",
            "customer_city": "city",
            "customer_state": "state"
        }
    },

    "products": {
        "file": PROCESSED_DIR / "products_list.csv",
        "columns": {
            "product_id": "product_id",
            "product_category_name": "category",
            "product_name_length": "name_length",
            "product_description_length": "description_length",
            "product_photos_qty": "photo_quantity",
            "product_weight_g": "weight_g",
            "product_length_cm": "length_cm",
            "product_height_cm": "heigth_cm",
            "product_width_cm": "width_cm"
        }
    },

    "sellers": {
        "file": PROCESSED_DIR / "sellers_list.csv",
        "columns": {
            "seller_id": "seller_id",
            "seller_zip_code_prefix": "zip_code",
            "seller_city": "city",
            "seller_state": "state"
        }
    },

    "orders": {
        "file": PROCESSED_DIR / "order_list.csv",
            "columns": {
                "order_id": "order_id",
                "customer_id": "customer_id",
                "order_status": "order_status",
                "order_purchase_timestamp": "purchase_time",
                "order_approved_at": "approval_time",
                "order_delivered_carrier_date": "carrier_delivery_time",
                "order_delivered_customer_date": "order_delivery_time",
                "order_estimated_delivery_date": "estimated_delivery_time"
            }
        },

    "order_items": {
        "file": PROCESSED_DIR / "order_items_list.csv",
        "columns": {
            "order_id": "order_id",
            "order_item_id": "order_item_id",
            "product_id" : "product_id",
            "seller_id": "seller_id",
            "shipping_limit_date": "shipping_limit",
            "price": "price",
            "freight_value": "freight_value"
        
        }
    },

    "order_payments": {
        "file": PROCESSED_DIR / "order_payments_list.csv",
        "columns": {
            "order_id": "order_id",
            "payment_sequential": "payment_sequential",
            "payment_type": "payment_type",
            "payment_installments": "payment_installments",
            "payment_value": "payment_value"
        }
    },

    "order_reviews": {
        "file": PROCESSED_DIR / "order_reviews_list.csv",
        "columns": {
            "review_id": "review_id",
            "order_id": "order_id",
            "review_score": "review_score",
            "review_comment_title": "title",
            "review_comment_message": "comment",
            "review_creation_date": "creation_timestamp",
            "review_answer_timestamp": "answer_timestamp"
        }
    },
    "geolocations": {
        "file": PROCESSED_DIR / "geolocation_list.csv",
        "columns": {
            "geolocation_zip_code_prefix": "zip_code",
            "geolocation_lat": "latitude",
            "geolocation_lng": "longitude",
            "geolocation_city": "city",
            "geolocation_state": "state"
        }
    }
}