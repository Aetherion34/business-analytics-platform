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
    "credit_card"
    "boleto"
    "voucher"
    "debit_card"
    "not_defined"
]
MIN_REVIEW_SCORE = 1
MAX_REVIEW_SCORE = 5