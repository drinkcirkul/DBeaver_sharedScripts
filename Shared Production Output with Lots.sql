--This is the Finished Good production run, detail, WITH lots
--Use the Max_lot_completed_date as THE date when the production was finished
--Change the WHERE clause as needed
select 
	rpro.production_run_id
	, rpro.output_sku 
	, rpro.output_type 
	, rpro.lot_location_code 
	, rpro.lot_location_name 
	, rpro.lot_machine_name 
	, rpro.lot_machine_code 
	, rpro.lot_operator_1_code 
	, rpro.lot_operator_1_name 
	, pe.cat3desc
	, timezone('America/New_York',rpro.lot_completed_timestamp) as Actual_Run_Date_America_New_York
	, rpro.output_quantity_kept
	, rpro.output_quantity_scrapped
	, rpro.lot_code
	, rpro.lot_completed_timestamp
	, rpr.is_from_webapp 
	
	from cirkul_warehouse_logs.raw_production_run_outputs rpro 
	left join cirkul_warehouse.paycom_employees pe on pe.eecode = lot_operator_1_code 
	left join cirkul_warehouse_logs.raw_production_runs rpr on rpr.production_run_id  = rpro.production_run_id 
	
	where rpr.is_from_webapp = true 
	and rpro.production_run_id = 20607
	--Production run below is incorrect data
	--where production_run_id  = 11255
	--where run_date = '2023-05-05'
	--where rpro.lot_machine_name = 'mespack01'
		--and run_date > '2023-05-01' 
	
	--order by rpr.production_run_id 
	