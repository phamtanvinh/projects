-- TEST LOGGER
DECLARE
V_LOGGER LOGGER;
BEGIN
V_LOGGER := NEW LOGGER();
V_LOGGER.PRC_PRINT_INFO();
sys.dbms_lock.sleep(1);
V_LOGGER.PRC_UPDATE();
V_LOGGER.PRC_PRINT_INFO();
sys.dbms_lock.sleep(2);
V_LOGGER.PRC_UPDATE();
V_LOGGER.PRC_PRINT_INFO();
END;
/

-- TEST LOGGING_EXCEPTION
DECLARE
V_LOGGER LOGGING_EXCEPTION;
BEGIN
NULL;
V_LOGGER := NEW LOGGING_EXCEPTION();
V_LOGGER.PRC_UPDATE();
V_LOGGER.PRC_PRINT_INFO();
sys.dbms_lock.sleep(1);
V_LOGGER.PRC_UPDATE();
V_LOGGER.PRC_PRINT_INFO();
END;
/

-- TEST LOGGING_EXCEPTION FROM LOGGER AND BACKTRACE
DECLARE
    V_LOGGER LOGGER;
    V_LOGGER_COPY LOGGER;
    V_LOGGER_1 LOGGING_EXCEPTION;
BEGIN
    V_LOGGER := NEW LOGGER();
    V_LOGGER_COPY := NEW LOGGER();
    V_LOGGER_1 := NEW LOGGING_EXCEPTION();
    
    V_LOGGER.UNIT_NAME := 'TEST';
    --V_LOGGER.PRC_PRINT_INFO();
    V_LOGGER_COPY.PRC_INIT_FROM_LOGGER(PI_LOGGER => V_LOGGER);
    
    sys.dbms_lock.sleep(1);
    V_LOGGER_COPY.PRC_UPDATE();
    --V_LOGGER_COPY.PRC_PRINT_INFO();
    
    sys.dbms_lock.sleep(1);
    V_LOGGER.UNIT_TYPE := 'LOGGIN_EXCEPTION';
    V_LOGGER_1.PRC_INIT_FROM_LOGGER(PI_LOGGER => V_LOGGER);
    V_LOGGER_1.PRC_PRINT_INFO();
    RAISE NO_DATA_FOUND;
EXCEPTION
    WHEN OTHERS THEN
        sys.dbms_lock.sleep(1);
        V_LOGGER_1.PRC_INIT_ERROR();
        V_LOGGER_1.PRC_PRINT_INFO();
END;
/

-- TEST LOGGING_RUNNING_TIME
DECLARE
    V_LOGGER LOGGING_RUNNING_TIME;
    V_LOGGER_TMP LOGGER;
BEGIN
    V_LOGGER := NEW LOGGING_RUNNING_TIME();
    V_LOGGER_TMP := NEW LOGGER();

    --V_LOGGER_TMP.PRC_PRINT_INFO();
    
    V_LOGGER.PRC_INIT_FROM_LOGGER(V_LOGGER_TMP, 
        PI_DESCRIPTION => 'INITILIZE FROM LOGGER',
        PI_UNIT_NAME => 'LOGGING_RUNNING_TIME');
    V_LOGGER.PRC_PRINT_INFO();
    sys.dbms_lock.sleep(1);
    V_LOGGER.PRC_UPDATE_STEP(PI_STEP_NAME => '010', PI_DESCRIPTION => 'STEP 1');
    V_LOGGER.PRC_PRINT_INFO();
    sys.dbms_lock.sleep(2);
    V_LOGGER.PRC_UPDATE_STEP(PI_STEP_NAME => '020', PI_DESCRIPTION => 'STEP 2');
    V_LOGGER.PRC_PRINT_INFO();
END;
/

-- TEST PACKAGE INTIALIZE LOGGING
DECLARE
    LOGGER_1 LOGGING_RUNNING_TIME;
    LOGGER_2 LOGGING_EXCEPTION;
BEGIN
    DB_UTIL.PRC_INIT_LOGGING(LOGGER_1, LOGGER_2, 'VINHPT', 'TEST PROCESSING', 'PROCESSING');
    sys.dbms_lock.sleep(2);
    LOGGER_1.PRC_UPDATE_STEP(PI_STEP_NAME => '010', PI_DESCRIPTION => 'STEP 1');
    LOGGER_1.PRC_PRINT_INFO();
    LOGGER_2.PRC_PRINT_INFO();
END;