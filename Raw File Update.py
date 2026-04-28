# In your notebook or a quick script
import pandas as pd
import duckdb
con = duckdb.connect(r"D:\Meowtakes\shelter.duckdb")

intakes_df = con.execute("SELECT * FROM raw_intakes").df()
outcomes_df = con.execute("SELECT * FROM raw_outcomes").df()

intakes_df.to_csv(r"D:\Downloads\austin_intakes.csv", index=False)
outcomes_df.to_csv(r"D:\Downloads\austin_outcomes.csv", index=False)

print(f"Intakes: {len(intakes_df)} rows")
print(f"Outcomes: {len(outcomes_df)} rows")