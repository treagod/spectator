sql_data = configuration_data()
sql_data.set('SQL', run_command('cat', files('init.sql'),).stdout().strip())
sql_data.set('CUSTOM_ORDER_MOVE_REQUEST_AFTER_REQUEST', run_command(
    'cat',
    files('custom_order/move_request_after_request.sql'),
).stdout().strip())


sql_init_header = configure_file(
    input: 'init_sql.vala.in',
    output: 'init_sql.vala',
    configuration: sql_data
)
