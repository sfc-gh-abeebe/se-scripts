## Overview
Today, Snowflake has a ingest file size limit of 16MB. This applies to selecting from stages as well as loading large JSON documents into a variant column.
This folder contains the following scripts:
* split_json.sql
* json-simple-1.1.1.jar

## Setup Instructions
1. Upload the dependencies to a external stage or to an internal Snowflake stage

### Example Using SnowSQL
```
put file:///Users/abeebe/Downloads/GitHub/se-scripts/split_large_json/json-simple-1.1.1.jar @~/stage/ auto_compress=false;
```
1. Update the `imports` line in the function to point to the stage where the parsing file was loaded
2. Create the function using the code in the `split_json.sql` file
3. Execute the function using the following SQL

The function `StripInnerArray` takes two arguments. The first will be the location of the file (including stage reference). The second is the parent element of the JSON object to start parsing at.

```
select OBJECT_INSERT(root, 'orders', node)
from table(StripInnerArray('@~/staged/my_large_json_file.json','orders'));
```

For example, say we have a JSON object like the following:
```
{
    "firstName": "Amber",
    "lastName": "Beebe",
    "email": "amber.beebe@snowflake.com",
    "orders": {
        1000: {
            "productSKU": 123,
            "orderDate": "2022-12-27"
        },
        1001: {
            "productSKU": 254,
            "orderDate": "2023-01-04"
        },
        1002: {
            "productSKU": 999,
            "orderDate": "2023-01-12"
        }
    }   
}
```
We want to flatten the nested objects in the "orders" object to show one order per row, however the file `my_large_json_file.json` is larger than 16MB and Snowflake will not allow us to transform in flight or during ingest.

If we call the function, as demonstrated above, the result will be:

```
    {   "email": "amber.beebe@snowflake.com",   "firstName": "Amber",   "lastName": "Beebe",   "orders": {     "orderDate": "2023-01-12",     "productSKU": 999   } }
    {   "email": "amber.beebe@snowflake.com",   "firstName": "Amber",   "lastName": "Beebe",   "orders": {     "orderDate": "2023-01-04",     "productSKU": 254   } }
    {   "email": "amber.beebe@snowflake.com",   "firstName": "Amber",   "lastName": "Beebe",   "orders": {     "orderDate": "2022-12-27",     "productSKU": 123   } }
```