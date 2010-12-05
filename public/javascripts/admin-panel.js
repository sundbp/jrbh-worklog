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
  
  if ($("#billing_info_start_date").length > 0) {
    $("#billing_info_start_date").datepicker({dateFormat: 'yy-mm-dd'});
  }
  
  if ($("#billing_info_end_date").length > 0) {
    $("#billing_info_end_date").datepicker({dateFormat: 'yy-mm-dd'});
  }

  if($("#role_allocation_ongoing").length > 0) {
    if($("#role_allocation_ongoing").attr("checked")) {
      $("#role_allocation_end_date").attr("disabled", true);
    }
    else {
      $("#role_allocation_end_date").removeAttr("disabled");
    }
    $("#role_allocation_ongoing").change(function() {
      if($("#role_allocation_ongoing").attr("checked")) {
        $("#role_allocation_end_date").attr("disabled", true);
      }
      else {
        $("#role_allocation_end_date").removeAttr("disabled");
      }
    });
  }

  if ($("#role_allocation_start_date").length > 0) {
    $("#role_allocation_start_date").datepicker({dateFormat: 'yy-mm-dd'});
  }
  
  if ($("#role_allocation_end_date").length > 0) {
    $("#role_allocation_end_date").datepicker({dateFormat: 'yy-mm-dd'});
    $("#role_allocation_end_date").change(function() {
      $("#role_allocation_ongoing").attr("checked", false);
    });
  } 

  if($("#billing_rate_ongoing").length > 0) {
    if($("#billing_rate_ongoing").attr("checked")) {
      $("#billing_rate_end_date").attr("disabled", true);
    }
    else {
      $("#billing_rate_end_date").removeAttr("disabled");
    }
    $("#billing_rate_ongoing").change(function() {
      if($("#billing_rate_ongoing").attr("checked")) {
        $("#billing_rate_end_date").attr("disabled", true);
      }
      else {
        $("#billing_rate_end_date").removeAttr("disabled");
      }
    });
  }

  if ($("#billing_rate_start_date").length > 0) {
    $("#billing_rate_start_date").datepicker({dateFormat: 'yy-mm-dd'});
  }
  
  if ($("#billing_rate_end_date").length > 0) {
    $("#billing_rate_end_date").datepicker({dateFormat: 'yy-mm-dd'});
    $("#billing_rate_end_date").change(function() {
      $("#billing_rate_ongoing").attr("checked", false);
    });
  } 
  
});
