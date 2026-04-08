import pandas as pd
import psycopg2
import os
from dotenv import load_dotenv
from pathlib import Path
from datetime import datetime
from time import perf_counter

# ==============================
# CONFIGURATION
# ==============================
load_dotenv(dotenv_path=Path(__file__).resolve().parents[2] / '.env')

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATASET_DIR = PROJECT_ROOT / 'dataset'
    
DB_CONFIG = {
  'host': os.getenv('DB_HOST'),
  'port': int(os.getenv('DB_PORT', '5432')),
  'dbname': os.getenv('DB_NAME'),
  'user': os.getenv('DB_USER'),
  'password': os.getenv('DB_PASSWORD')
}

FILE_PATHS = {
  'product_catalog': DATASET_DIR / 'Sale Report.csv',
  'amazon_sales': DATASET_DIR / 'Amazon Sale Report.csv'
}


# ==============================
# HELPERS
# ==============================

def log(msg):
    print(f'[{datetime.now().strftime("%Y-%m-%d %H:%M:%S")}] {msg}')

def get_connection():
    missing_vars = [
    key for key, value in DB_CONFIG.items()
    if value is None or value == ''
    ]
    if missing_vars:
        raise ValueError(f'Missing database config values: {", ".join(missing_vars)}')

    return psycopg2.connect(**DB_CONFIG)


# ==============================
# LOAD FUNCTION
# =============================

# Load data using COPY (omit ingestion_date)
def load_table(table_name, file_path):
  full_table_name = f'raw.{table_name}'

  try:
      log(f'Starting to load for {full_table_name} from file {Path(file_path).name}')

      # Load CSV into DataFrame
      df = pd.read_csv(file_path)

      # Strip whitespace from headers
      df.columns = df.columns.str.strip()

      # Rename columns to match table schema
      if table_name == 'amazon_sales':
          df = df.rename(columns={
              "Order ID": "order_id",
              "Date": "order_date",
              "Status": "order_status",
              "Fulfilment": "fulfillment_type",
              "Sales Channel": "sales_channel",
              "ship-service-level": "ship_service_level",
              "Style": "product_style",
              "SKU": "product_sku",
              "Category": "product_category",
              "Size": "product_size",
              "ASIN": "product_asin",
              "Courier Status": "courier_status",
              "Qty": "quantity",
              "Currency": "currency",
              "Amount": "line_amount",
              "ship-city": "ship_city",
              "ship-state": "ship_state",
              "ship-postal-code": "ship_postal_code",
              "ship-country": "ship_country",
              "promotion-ids": "promotion_ids",
              "B2B": "is_b2b",
              "fulfilled-by": "fulfillment_service"
          })
          # Type cast numeric columns
          df['quantity'] = pd.to_numeric(df['quantity'], errors='coerce').fillna(0).astype(int)
          df['line_amount'] = pd.to_numeric(df['line_amount'], errors='coerce').fillna(0.0).astype(float)
      elif table_name == 'product_catalog':
          df = df.rename(columns={
              "SKU Code": "product_sku",
              "Design No.": "design_number",
              "Stock": "stock_quantity",
              "Category": "category",
              "Size": "size",
              "Color": "color"
          })
          # Type cast numeric columns
          df['stock_quantity'] = pd.to_numeric(df['stock_quantity'], errors='coerce').fillna(0).astype(int)

      # Add ingestion date
      df['ingestion_date'] = pd.Timestamp.now()

      with get_connection() as conn:
          with conn.cursor() as cur:
              # Truncate table before loading
              log(f'Truncating table {full_table_name}...')
              cur.execute(f'TRUNCATE TABLE {full_table_name}')

              # Ensure DataFrame has exactly the columns in the table
              if table_name == 'amazon_sales':
                  df = df[[
                      "order_id","order_date","order_status","fulfillment_type",
                      "sales_channel","ship_service_level","product_style","product_sku",
                      "product_category","product_size","product_asin","courier_status",
                      "quantity","currency","line_amount","ship_city","ship_state",
                      "ship_postal_code","ship_country","promotion_ids","is_b2b","fulfillment_service","ingestion_date"
                  ]]
              elif table_name == 'product_catalog':
                  df = df[[
                      "product_sku","design_number","stock_quantity","category","size","color","ingestion_date"
                  ]]

              # Load data using COPY
              log(f'Loading data into {full_table_name}...')
              output = df.to_csv(index=False, header=False)
              cur.copy_expert(f"COPY {full_table_name} FROM STDIN WITH CSV", pd.io.common.StringIO(output))
              conn.commit()

      log(f'Finished loading {full_table_name}')

  except Exception as e:
      log(f'Error loading {full_table_name}: {e}')


# ==============================
# MAIN
# ==============================
if __name__ == '__main__':
  start_time = perf_counter()

  for table_name, file_path in FILE_PATHS.items():
    load_table(table_name, file_path)

  elapsed_seconds = perf_counter() - start_time
  log(f'Total load time: {elapsed_seconds:.2f} seconds')