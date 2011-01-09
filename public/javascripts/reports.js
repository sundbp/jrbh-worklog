Date.format = 'yy-mm-dd'
$(function() {
  
  if ($("#start_date").length > 0) {
    $("#start_date").datepicker({dateFormat: 'yy-mm-dd'});
  }  
  if ($("#end_date").length > 0) {
    $("#end_date").datepicker({dateFormat: 'yy-mm-dd'});
  }

});
