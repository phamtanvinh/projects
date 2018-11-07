/**
Features:
- [demo 1]: create dynamic action on item to refresh multi regions
- [demo 2]: submit items when leaving page
- [demo 3]: submit form when enter key is pressed
- [demo 4]: use ajax callback and hide all selected options in other selects


*/


/* 
[demo 1]: create dynamic action on item to refresh multi regions
- Create Dynamic Action: 
    + Event: Change
    + Selection Type: Item(s)
    + Item(s): YOUR_ITEM_NAME
- Create True Action:
    + Action: Execute Javascript Code
    + Code: [Put below code here and modify regions variable]
*/

var selector = this.triggeringElement;
// pass your regions here

var regions = ['region1_id', 'region2_id']

apex.server.process(
    'DUMMY',
    {pageItems: selector},
    {
        dataType: 'text',
        success: function(){
            console.log('Refresh region here');
            $.each(regions, function(index, region_id){
                apex.region(region_id).refresh();
            });
        }
    }
)



/*
[demo 2]: submit items when leaving page
- Put your code in "Function and Global Variable Declaration" of Page Properties
- Pass your items which you want to submit
*/

var items = '#item_1,#item_2'

$(document).ready(function(){
    $(window).on('beforeunload', function(){
        
        apex.server.process(
            'DUMMY',
            {pageItems: items},
            {
                dataType: 'text'
            }
        )
        .done(function(){
            console.log('Submit items successfully');
        });
    });   
})



/*
[demo 3]: submit form when enter key is pressed
- Create dynamic Action:
    + Event: Key Press
    + Selection Type: Javascript Expression
    + Code: console.log('Key press!!!')
- Create True Action:
    + Action: Execute Javascript Code
    + Code: [Put below code here]

*/

$(document).keypress(function(e){
    if (e.which == 13){
        console.log('Press enter key!!!');
        apex.submit({request:'SUBMIT'});
    }
})



/*
[demo 4]: using ajax callback
- Create Ajax Callback:
    + Name: sp_name
    + Type: PL/SQL Code
    + PL/SQL Code: [Put [Code1] here]
    + Point: Ajax Callback
- Put [Code2] in "Function and Global Variable Declaration" of Page Properties, using for:
    + Apply Ajax Callback for tabular form
    + Listen Ajax complete
    + Add function for jQuery Object
    + Add functions for jQuery namespace
    + Hide all selected options in other select lists 
- Create Dynamic Action and pass corresponding parameters
*/

// [Code1]
// Create: sp_name
// Return: [{'value_name': value, 'display_name': value}, ]
DECLARE
    l_sql VARCHAR2(32700);
BEGIN
    l_sql := '[PUT YOUR SELECT STATEMENT HERE]'; 
    APEX_UTIL.JSON_FROM_SQL(l_sql);
END;



// [Code2]
// Add funtions for jQuery Object
// data: [{'value_name': value, 'display_name': value}, ]
$.fn.changeSelectSource = function(data, selected_value, value_name, display_name){
    selector = this;
    selector.empty();
    selector.append($("<option></option>").val('').text("- Select -"));

    $.each(data, function(index, item){
        selector.append($("<option></option>").val(item[value_name]).text(item[display_name]));
    });
    // console.log(selected_value);
    // this step sets selected option
    if( selector.find("option[value='" + selected_value + "']").length > 0){
        selector.val(selected_value );
    }
}

// Add functions for jQuery name space
$.extend({
    // apply ajax call back for select list
    sp_name: function(x01_value, affected_select_list, selected_value, value_name, display_name){ //call ajax callback
        apex.server.process( 
            'sp_name',
            { x01: x01_value}, 
            {    
                dataType: 'json',
                success: function(pData){
                    affected_select_list.changeSelectSource(pData.row, selected_value, value_name, display_name);
                    console.log('AJAX load successfully!!!');
                }
            }
        );
    }, 
    // hide all selected options in other selects 
    hideSelectedOptionFromOtherSelects: function(select_list){
        $("option").show();
        var selected_options = $(select_list).find("option[value!='']:selected");
        //console.log(selected_options);

        $(select_list).find("option[value!='']").not(":selected").each(function(i, option){
            $.each(selected_options, function(i, selected_option){
                if($(option).val() == $(selected_option).val()){
                    $(option).hide();
                }
            });
        });
    }
});

// Listen ajax complete
$(document).ajaxComplete(function(){
    $.hideSelectedOptionFromOtherSelects("select[headers='static_id']");
});

// Trigger change event for all selects with headers is static_id
$(document).ready(function(){
    $("select[headers='static_id']").change();
});


