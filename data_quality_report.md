# Data Quality Report

## 1. Overview

This report documents the data quality checks performed on the Olist Brazilian E-Commerce dataset after the data was loaded into PostgreSQL.

The objective of the Data Quality phase is to verify the integrity, consistency, completeness, and validity of the data before using it for analytical purposes and building the Data Warehouse.

The following areas were evaluated:

* Row counts
* Referential integrity
* Missing values
* Invalid and out-of-range values
* Categorical values
* Date consistency
* Business rules

The SQL queries used to perform these checks are available in:

`sql/data_quality_checks.sql`

---

## 2. Row Count Validation

Row counts were checked for all tables in the OLTP database.

| Table          | Row Count | Result |
| -------------- | --------: | ------ |
| customers      |    93,582 | PASS   |
| products       |    32,336 | PASS   |
| sellers        |     3,095 | PASS   |
| orders         |    95,088 | PASS   |
| order_items    |   112,267 | PASS   |
| order_payments |   103,848 | PASS   |
| order_reviews  |   102,986 | PASS   |
| geolocations   |   610,158 | PASS   |

All expected records were successfully loaded.

### Note

Physical line counts in the original CSV files were not used as the final source of truth because some CSV files contain quoted fields with embedded newlines and trailing empty lines.

Record counts were therefore verified using the actual parsed datasets and database tables.

---

## 3. Referential Integrity

Foreign key relationships were checked between the related tables.

The following relationships were validated:

* `orders.customer_id` → `customers.customer_id`
* `order_items.order_id` → `orders.order_id`
* `order_items.product_id` → `products.product_id`
* `order_items.seller_id` → `sellers.seller_id`
* `order_payments.order_id` → `orders.order_id`
* `order_reviews.order_id` → `orders.order_id`

### Result

**PASS**

No invalid foreign key references were detected.

All referenced records exist in their corresponding parent tables.

---

## 4. Missing Values

Required fields were checked for NULL values.

The checks covered:

* Customer location attributes
* Product attributes
* Seller location attributes
* Order purchase timestamp
* Order item attributes
* Payment values
* Review score and creation timestamp
* Geolocation attributes

### Result

**PASS**

All checked required fields contained no NULL values.

This indicates that no missing values were detected in the fields defined as mandatory for this Data Quality phase.

---

## 5. Invalid and Out-of-Range Values

Numerical and temporal values were checked for invalid values.

### Product attributes

The following fields were checked for negative values:

* `name_length`
* `description_length`
* `photo_quantity`

### Result

**PASS**

No negative values were detected.

### Geolocation

Latitude and longitude were checked against their valid geographical ranges:

* Latitude: `-90` to `90`
* Longitude: `-180` to `180`

### Result

**PASS**

No invalid geographical coordinates were detected.

---

## 6. Date Consistency

Order timestamps were checked according to their expected chronological sequence:

`purchase_time → approval_time → carrier_delivery_time → order_delivery_time`

The following conditions were used to identify invalid sequences:

* `purchase_time > approval_time`
* `approval_time > carrier_delivery_time`
* `carrier_delivery_time > order_delivery_time`

### Result

**PASS**

No orders violated the expected chronological sequence.

Review timestamps were also checked to ensure that the review creation timestamp does not occur after the review answer timestamp.

### Result

**PASS**

No invalid review timestamp sequences were detected.

---

## 7. Categorical Values

Categorical fields were checked against the expected values defined for the dataset.

The following attributes were validated:

* Customer states
* Seller states
* Order statuses
* Payment types
* Geolocation states

### Result

**PASS**

No unexpected categorical values were detected.

---

## 8. Business Rules

Additional business rules were evaluated to identify inconsistencies that cannot be detected through basic schema validation.

### 8.1 Orders without items

The check identified orders that do not have any corresponding records in `order_items`.

### Result

**1,571 orders**

These records require contextual interpretation because an order without items is not necessarily an invalid record for every possible order status.

The records were therefore not automatically removed during the cleaning phase.

---

### 8.2 Orders without payments

A check was performed to identify orders that do not have any corresponding payment record.

The initial result identified:

**2 orders without payments**

Further investigation showed that both orders have:

* `order_status = 'delivered'`
* Associated `order_items`
* A positive order value
* No corresponding record in `order_payments`

The two orders are:

| Order ID                           | Status    | Order Value |
| ---------------------------------- | --------- | ----------: |
| `bfbd0f9bdef84302105ad712db648a6c` | delivered |      143.46 |
| `1a57108394169c0b47d8f876acc9ba2d` | delivered |      129.94 |

### Result

**WARNING**

These records are considered source-data anomalies.

They were not automatically corrected because the missing payment information cannot be reliably reconstructed from the available data.

No artificial payment records were created and the original orders were retained.

---

### 8.3 Delivered orders without delivery date

A check was performed for orders where:

`order_status = 'delivered'`

but:

`order_delivery_time IS NULL`

### Result

**PASS**

No delivered orders were missing their delivery timestamp.

---

### 8.4 Payment consistency

Payment totals were compared with the total value calculated from order items:

`SUM(price + freight_value)`

The comparison was performed after aggregating both `order_items` and `order_payments` by `order_id` in order to avoid row multiplication caused by joining multiple items with multiple payments.

Small numerical differences were treated as floating-point/decimal tolerance issues.

After applying a tolerance of `0.01`, approximately 300 orders still showed differences.

These differences were not automatically classified as data quality errors because a difference between item totals and recorded payments does not necessarily provide enough evidence to determine that the underlying data is incorrect.

This check is therefore treated as an **exploratory business consistency check** rather than a mandatory data quality failure.

---

## 9. Cleaning Decisions

Not every detected anomaly was automatically modified.

The following principles were applied:

1. Values were corrected only when a reliable correction rule was available.
2. Records were not deleted solely because they violated an assumption.
3. Missing information was not artificially reconstructed.
4. Source-data anomalies were documented rather than hidden.
5. Business rules were evaluated according to the semantics of the dataset.

In particular, the two delivered orders without payment records were retained because there is insufficient information to reconstruct the missing payment records reliably.

---

## 10. Final Assessment

The OLTP dataset passed the main structural and validity checks.

### Summary

| Check                                  | Result                |
| -------------------------------------- | --------------------- |
| Row Counts                             | PASS                  |
| Referential Integrity                  | PASS                  |
| Missing Values                         | PASS                  |
| Numerical Ranges                       | PASS                  |
| Geographical Ranges                    | PASS                  |
| Date Consistency                       | PASS                  |
| Categorical Values                     | PASS                  |
| Delivered Orders without Delivery Date | PASS                  |
| Orders without Items                   | WARNING               |
| Delivered Orders without Payments      | WARNING               |
| Payment Consistency                    | WARNING / Exploratory |

The dataset is considered suitable for the next stage of the project.

The identified anomalies will be preserved and documented rather than artificially corrected.

The next phase is the design and construction of the analytical Data Warehouse.
