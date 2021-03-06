
-- TEST COLLECTION
DECLARE
    L_DICT  PKG_UTIL.DICTIONARY;
    L_KEY VARCHAR2(64);
BEGIN
    L_DICT('NAME') := 'VINH';
    L_DICT('JOB') := 'ENGINERR';
    L_KEY := L_DICT.FIRST;
    WHILE L_KEY IS NOT NULL
    LOOP
        DBMS_OUTPUT.PUT_LINE(L_KEY);
        DBMS_OUTPUT.PUT_LINE(L_DICT(L_KEY));
        L_KEY := L_DICT.NEXT(L_KEY);
    END LOOP;
END;
/

DECLARE
    L_DICT PKG_UTIL.DICTIONARY;
BEGIN
    L_DICT('NAME') := 'VINH';
    L_DICT('JOB') := 'ENGINEERING';
    pkg_util.prc_print_info(L_DICT);
    DBMS_OUTPUT.PUT_LINE(RPAD('NAME', 20, ' ')||'VINH');
    DBMS_OUTPUT.PUT_LINE(RPAD('JOB', 20, ' ')||'ENGINEERING');
END;
/
-- TEST TYP_TS_DIM
DECLARE
    L_TS_DIM    TYP_TS_DIM := TYP_TS_DIM();
BEGIN
    L_TS_DIM.PRC_PRINT_INFO();
    L_TS_DIM.PRC_UPDATE_START_TS_DIM();
    L_TS_DIM.PRC_PRINT_INFO();
    
END;

-- TEST TYP_ALL_TS_DIM
DECLARE 
    L_ALL_TS_DIM    TYP_ALL_TS_DIM := TYP_ALL_TS_DIM();
BEGIN
    L_ALL_TS_DIM.PRC_PRINT_INFO();
END;
