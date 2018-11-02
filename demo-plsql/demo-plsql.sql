declare 
    x1 int ;
begin
    x1 := NULL;
    if x1 > 2 
    then 
        dbms_output.put_line('True');
    elsif x1 is null
    then
        dbms_output.put_line('this value is null');
    else 
        dbms_output.put_line('False'); 
    end if;
end;
/

begin
    <<loop1>>
    for outer_idx in 1..5
    loop
        <<loop2>>
        for inner_idx in 1..5
        loop
            continue when mod(outer_idx*inner_idx, 2) = 0;
            dbms_output.put_line(outer_idx*inner_idx);

        end loop;
    end loop;
end;
/

declare 
    var1 int;
    var2 int;
begin
    var1 := &var1;
    var2 := &var2;
    
    dbms_output.put_line(var1 + var2);
end;
/