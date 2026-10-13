VALID_STATUS = [
    "created", "approved", "processing", "shipped",
    "delivered", "canceled", "unavailable", "invoiced"
]

DEFAULT_STATUS = "unknown"
VALID_STATES = [
    "AC", "AL", "AP", "AM", "BA", "CE", "DF",
    "ES", "GO", "MA", "MT", "MS", "MG",
    "PA", "PB", "PR", "PE", "PI", "RJ",
    "RN", "RS", "RO", "RR", "SC", "SP",
    "SE", "TO"
]
VALID_PAYMENT_TYPES = [
    "credit_card",
    "boleto",
    "voucher",
    "debit_card",
    "not_defined",
]
MIN_REVIEW_SCORE = 1
MAX_REVIEW_SCORE = 5
REQUIRED_DATES_BY_STATUS = {
    "created": [
        "order_purchase_timestamp",
        "order_estimated_delivery_date"
    ],
    "approved": [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_estimated_delivery_date"
    ],
    "processing": [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_estimated_delivery_date"
    ],
    "shipped": [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_estimated_delivery_date"
    ],
    "delivered": [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date"
    ],
    "canceled": [
        "order_purchase_timestamp",
        "order_estimated_delivery_date"
    ],
    "unavailable": [
        "order_purchase_timestamp",
        "order_estimated_delivery_date"
    ],
    "invoiced": [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_estimated_delivery_date"
    ]
}