// javascript to setup a jquery-weekcalendar widget

$(document).ready(function() {

    var $calendar = $('#calendar');

    $calendar.weekCalendar({
        timeslotsPerHour : 2,
        allowCalEventOverlap : true,
        overlapEventsSeparate: true,
        firstDayOfWeek : 6,
        businessHours :{start: 8, end: 19, limitDisplay: false },
        daysToShow : 7,
        timeFormat : "G:i",
        use24Hour : true,
        dateFormat : "j M Y",
        height : function($calendar) {
           return $(window).height() - $('#header').outerHeight() - $('#footer').outerHeight() - 1;
        },
        eventRender : function(calEvent, $event) {
            if (calEvent.end.getTime() > new Date().getTime()) {
                $event.css("backgroundColor", "#aaa");
                $event.find(".wc-time").css({
                    "backgroundColor" : "#999",
                    "border" : "1px solid #888"
                });
            }
        },
        eventNew : function(calEvent, $event) {
            var $dialogContent = $("#event_edit_container");
            resetForm($dialogContent);
            var startField = $dialogContent.find("select[name='start']").val(calEvent.start);
            var endField = $dialogContent.find("select[name='end']").val(calEvent.end);
            var worklogTaskIdField = $dialogContent.find("select[id='worklog_task_id']");
            var userIdField = $dialogContent.find("input[name='user_id']");

            $dialogContent.dialog({
                modal: true,
                title: "New work period",
                close: function() {
                    $dialogContent.dialog("destroy");
                    $dialogContent.hide();
                    $('#calendar').weekCalendar("removeUnsavedEvents");
                },
                buttons: {
                    save : function() { handleSave(calEvent, "create"); },
                    cancel : function() { $dialogContent.dialog("close"); }
                }
            }).show();

            worklogTaskIdField.bind('keypress', function(e) { handleEnterPress(e, calEvent, "create"); } );
            startField.bind('keypress', function(e) { handleEnterPress(e, calEvent, "create"); } );
            endField.bind('keypress', function(e) { handleEnterPress(e, calEvent, "create"); } );

            $dialogContent.find("input[class='date-holder']").val($calendar.weekCalendar("formatDate", calEvent.start));
            setupStartAndEndTimeFields(startField, endField, calEvent, $calendar.weekCalendar("getTimeslotTimes", calEvent.start));
        },
        eventClick : function(calEvent, $event) {
            var $dialogContent = $("#event_edit_container");
            resetForm($dialogContent);
            var startField = $dialogContent.find("select[name='start']").val(calEvent.start);
            var endField = $dialogContent.find("select[name='end']").val(calEvent.end);
            var worklogTaskIdField = $dialogContent.find("select[id='worklog_task_id']").val(calEvent.title);
            var userIdField = $dialogContent.find("input[name='user_id']");

            $dialogContent.dialog({
                modal: true,
                title: "Edit work period",
                close: function() {
                    $dialogContent.dialog("destroy");
                    $dialogContent.hide();
                    $('#calendar').weekCalendar("removeUnsavedEvents");
                },
                buttons: {
                    save : function() { handleSave(calEvent, "update"); },
                    "delete" : function() {
                        $.ajax({
                            dataType: "json",
                            type: "POST",
                            url: '/work_periods/destroy',
                            data: {id : calEvent.id },
                            success: function(result) {
                                $calendar.weekCalendar("removeEvent", result.id);
                                $dialogContent.dialog("close");
                            },
                            error: function(req, testStatus, errorThrown) {
                                alert("Data could not be deleted properly - get Patrik to investiagte!");
                                $dialogContent.dialog("close");
                            }
                        });
                    },
                    cancel : function() { $dialogContent.dialog("close"); }
                }
            }).show();

            worklogTaskIdField.bind('keypress', function(e) { handleEnterPress(e, calEvent, "update"); } );
            startField.bind('keypress', function(e) { handleEnterPress(e, calEvent, "update"); } );
            endField.bind('keypress', function(e) { handleEnterPress(e, calEvent, "update"); } );

            $dialogContent.find(".date_holder").text($calendar.weekCalendar("formatDate", calEvent.start));
            setupStartAndEndTimeFields(startField, endField, calEvent, $calendar.weekCalendar("getTimeslotTimes", calEvent.start));
            $(window).resize().resize(); //fixes a bug in modal overlay size ??
        },
        eventDrop : function(calEvent, $event) { handleSave(calEvent, "drop"); },
        eventResize : function(calEvent, $event) { handleSave( calEvent, "resize"); },
        eventMouseover : function(calEvent, $event) {
            // TODO: show tooltip with comment field
        },
        eventMouseout : function(calEvent, $event) {
            // TODO: remove tooltip with comment field
        },
        noEvents : function() {
        },
        data : function(start, end, callback) {
            $.getJSON("/work_periods/", {
                start: start,
                end : end
            }, function(result) {
                callback({ events : result });
            });
        }
    });

    function resetForm($dialogContent) {
        // TODO: in case we want to do something smart
    }

    function handleEnterPress(e, calEvent, caller) {
        if(e.keyCode && e.keyCode == $.ui.keyCode.ENTER ) {
            handleSave( calEvent, caller);
            return(true);
        }
    }

    function handleSave(calEvent, caller) {
        var $calendar = $('#calendar');
        var $dialogContent = $("#event_edit_container");
        var startField = $dialogContent.find("select[name='start']");
        var endField = $dialogContent.find("select[name='end']");
        var worklogTaskIdField = $dialogContent.find("select[id='worklog_task_id']");
        var userIdField = $dialogContent.find("input[name='user_id']");

        if(caller == "create" || caller == "update" ) {
            calEvent.start = new Date(startField.val());
            calEvent.end = new Date(endField.val());
            calEvent.user_id = userIdField.val();
            calEvent.worklog_task_id = worklogTaskIdField.val();
        }

        var postData = {
            user_id : calEvent.user_id,
            worklog_task_id : calEvent.worklog_task_id,
            start : calEvent.start,
            end : calEvent.end
        };

        var url;
        if(caller == "create") {
            url = '/work_periods/create';
        } else {
            url = '/work_periods/update';
            postData["id"] = calEvent.id;
        }

        $.ajax({
            dataType: "json",
            type: "POST",
            url: url,
            data: postData,
            success: function(result) {
                calEvent.id = result.id;
                calEvent.title = result.title;
                $calendar.weekCalendar("removeUnsavedEvents");
                if(caller == "create" || caller == "update" )
                    $calendar.weekCalendar("updateEvent", calEvent);
                $dialogContent.dialog("close");
            },
            error: function(req, testStatus, errorThrown) {
                alert("Data could not be added properly - get Patrik to investiagte!");
                $dialogContent.dialog("close");
            }
        });
    }

    /*
     * Sets up the start and end time fields in the calendar event
     * form for editing based on the calendar event being edited
     */
    function setupStartAndEndTimeFields($startTimeField, $endTimeField, calEvent, timeslotTimes) {

        for (var i = 0; i < timeslotTimes.length; i++) {
            var startTime = timeslotTimes[i].start;
            var endTime = timeslotTimes[i].end;
            var startSelected = "";
            if (startTime.getTime() === calEvent.start.getTime()) {
                startSelected = "selected=\"selected\"";
            }
            var endSelected = "";
            if (endTime.getTime() === calEvent.end.getTime()) {
                endSelected = "selected=\"selected\"";
            }
            $startTimeField.append("<option value=\"" + startTime + "\" " + startSelected + ">" + timeslotTimes[i].startFormatted + "</option>");
            $endTimeField.append("<option value=\"" + endTime + "\" " + endSelected + ">" + timeslotTimes[i].endFormatted + "</option>");

        }
        $endTimeOptions = $endTimeField.find("option");
        $startTimeField.trigger("change");
    }

    var $endTimeField = $("select[name='end']");
    var $endTimeOptions = $endTimeField.find("option");

    //reduces the end time options to be only after the start time options.
    $("select[name='start']").change(function() {
        var startTime = $(this).find(":selected").val();
        var currentEndTime = $endTimeField.find("option:selected").val();
        $endTimeField.html(
            $endTimeOptions.filter(function() {
                return startTime < $(this).val();
            })
        );

        var endTimeSelected = false;
        $endTimeField.find("option").each(function() {
            if ($(this).val() === currentEndTime) {
                $(this).attr("selected", "selected");
                endTimeSelected = true;
                return false;
            }
        });

        if (!endTimeSelected) {
            //automatically select an end date 2 slots away.
            $endTimeField.find("option:eq(1)").attr("selected", "selected");
        }
    });
});
