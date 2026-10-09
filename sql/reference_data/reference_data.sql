CREATE TABLE IF NOT EXISTS valid_order_statuses (
    order_status TEXT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS valid_states (
    state TEXT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS valid_payment_methods (
    payment_method TEXT PRIMARY KEY
);

INSERT INTO valid_order_statuses (order_status)
VALUES
    ('delivered'),
    ('shipped'),
    ('canceled'),
    ('unavailable'),
    ('invoiced'),
    ('processing'),
    ('created'),
    ('approved')
ON CONFLICT DO NOTHING;

INSERT INTO valid_states (state)
VALUES
    ('SP'),
    ('MG'),
    ('RJ'),
    ('RS'),
    ('PR'),
    ('SC'),
    ('BA'),
    ('GO'),
    ('ES'),
    ('PE'),
    ('DF'),
    ('MT'),
    ('CE'),
    ('PA'),
    ('MS'),
    ('MA'),
    ('PB'),
    ('RN'),
    ('PI'),
    ('AL'),
    ('TO'),
    ('SE'),
    ('RO'),
    ('AM'),
    ('AC'),
    ('AP'),
    ('RR')
ON CONFLICT DO NOTHING;

INSERT INTO valid_payment_methods (payment_method)
VALUES
    ('credit_card'),
    ('boleto'),
    ('voucher'),
    ('debit_card'),
    ('not_defined')
ON CONFLICT DO NOTHING;

