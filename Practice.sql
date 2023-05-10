--This is our practice wildcard SQL statement
select * from cirkul_warehouse_logs.raw_production_runs rpr
	where production_run_id = 20607
	and run_date > '2023-05-01'
	order by run_date desc
	;

--This is our next practice with actual interesting data	
select production_run_id , output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
	, lot_operator_1_code ,lot_operator_1_name , lot_operator_2_code , lot_operator_2_name
	,output_quantity_kept , output_quantity_scrapped, *
	--,sum(output_quantity_kept) sum_qty_kept, sum(output_quantity_scrapped) as sum_qty_scrap 
	from cirkul_warehouse_logs.raw_production_run_outputs rpro 
	where production_run_id = 20607
	--group by output_sku , output_type , lot_location_code , lot_location_name , lot_machine_name , lot_machine_code 
	--, lot_operator_1_code ,lot_operator_1_name , lot_operator_2_code , lot_operator_2_name, production_run_id 
	;
