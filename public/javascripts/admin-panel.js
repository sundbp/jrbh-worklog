Date.format = 'yy-mm-dd'
$(function() {
  if($("#timeplan_ongoing").length > 0) {
    if($("#timeplan_ongoing").attr("checked")) {
      $("#timeplan_end_date").attr("disabled", true);
    }
    else {
      $("#timeplan_end_date").removeAttr("disabled");
    }
    $("#timeplan_ongoing").change(function() {
      if($("#timeplan_ongoing").attr("checked")) {
        $("#timeplan_end_date").attr("disabled", true);
      }
      else {
        $("#timeplan_end_date").removeAttr("disabled");
      }
    });
  }

  if ($("#timeplan_start_date").length > 0) {
    $("#timeplan_start_date").datepicker({dateFormat: 'yy-mm-dd'});
  }
  
  if ($("#timeplan_end_date").length > 0) {
    $("#timeplan_end_date").datepicker({dateFormat: 'yy-mm-dd'});
    $("#timeplan_end_date").change(function() {
      $("#timeplan_ongoing").attr("checked", false);
    });
  }  
});
