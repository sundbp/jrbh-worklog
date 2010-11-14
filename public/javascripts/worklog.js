// javascript to setup a jquery-weekcalendar widget

$(document).ready(function() {
    var $urlBase = "/";
    //var $urlBase = "/worklog/";

    // setup calendar
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
            // get color
            if(calEvent.color) {
                var lighter = lighterColor(calEvent.color, 0.14);
                var darker = darkerColor(calEvent.color, 0.14);
                $event.css("backgroundColor", lighter);
                $event.find(".wc-time").css({
                    "backgroundColor" : calEvent.color,
                    "border" : "1px solid " + darker
                });
            }
            // add tooltip
            var tooltip_conf = {
              content: {
                text: calEvent.comment
              },
              position : {
                target: 'mouse',
                adjust: {
                  mouse: false,
                  x: 20
                }
              },
              style: {
                classes: 'ui-tooltip-worklog'
              },
              show: {
                delay: 500,
                solo: true
              },
              hide: {
                event: 'click mouseleave'
              }
            };
            if(calEvent.comment != null && calEvent.comment != "\n" && calEvent.comment != "") {
              $event.find(".wc-time").qtip(tooltip_conf);
              $event.find(".wc-title").qtip(tooltip_conf);
            }
        },
        eventNew : function(calEvent, $event) {
            var $dialogContent = $("#event_edit_container");
            resetForm($dialogContent);
            var startField = $dialogContent.find("select[name='start']").val(calEvent.start);
            var endField = $dialogContent.find("select[name='end']").val(calEvent.end);
            var worklogTaskIdField = $dialogContent.find("select[id='worklog_task_id']");

            $dialogContent.dialog({
                modal: true,
                width: 460,
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
            var worklogTaskIdField = $dialogContent.find("select[id='worklog_task_id']").val(calEvent.worklog_task_id);

            $dialogContent.find("textarea[id='comment']").val(calEvent.comment);

            $dialogContent.dialog({
                modal: true,
                width: 460,
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
                            url: $urlBase + 'work_periods/destroy',
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

            $dialogContent.find("input[class='date-holder']").val($calendar.weekCalendar("formatDate", calEvent.start));
            setupStartAndEndTimeFields(startField, endField, calEvent, $calendar.weekCalendar("getTimeslotTimes", calEvent.start));
            $(window).resize().resize(); //fixes a bug in modal overlay size ??
        },
        eventDrop : function(calEvent, $event) { handleSave(calEvent, "drop"); },
        eventResize : function(calEvent, $event) { handleSave( calEvent, "resize"); },
        eventMouseover : function(calEvent, $event) {
            if(jQuery.data($event, "qtip"))
                $event.qtip("show");
        },
        eventMouseout : function(calEvent, $event) {
            if(jQuery.data($event, "qtip"))
                $event.qtip("hide");
        },
        noEvents : function() {
        },
        data : function(start, end, callback) {
            var $dialogContent = $("#event_edit_container");
            var user_id = $dialogContent.find("input[name='user_id']").val()
            var start_string = start.toISOString();
            var end_string   = end.toISOString();
            $.getJSON($urlBase + "work_periods/", {
                user_id: user_id,
                start: start_string,
                end : end_string
            }, function(result) {
                // update color legend
                $("#legend-content").find(".legend").each(function() {
                    var entry = jQuery.trim(this.textContent);
                    var $match = false;
                    jQuery.each(result, function() {
                        if(this.company == entry || (this.company + " - " + this.title) == entry)
                            $match = true;
                    });
                    if($match)
                        $(this).css({"display" : "block"});
                    else
                        $(this).css({"display" : "none"});
                });
                callback({ events : result });
            });
        }
    });

    function resetForm($dialogContent) {
        $dialogContent.find("textarea[name='comment']").val("");
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
        var commentField = $dialogContent.find("textarea[name='comment']");

        if(caller == "create" || caller == "update" ) {
            calEvent.start = new Date(startField.val());
            calEvent.end = new Date(endField.val());
            calEvent.user_id = userIdField.val();
            calEvent.worklog_task_id = worklogTaskIdField.val();
            calEvent.comment = commentField.val();
        }

        var start_string = calEvent.start.toISOString();
        var end_string = calEvent.end.toISOString();
        
        var postData = {
            user_id : calEvent.user_id,
            worklog_task_id : calEvent.worklog_task_id,
            start : start_string,
            end : end_string,
            comment : calEvent.comment
        };

        var url;
        if(caller == "create") {
            url = $urlBase + 'work_periods/create';
        } else {
            url = $urlBase + 'work_periods/update';
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
                calEvent.color = result.color;
                calEvent.comment = result.comment;
                $calendar.weekCalendar("removeUnsavedEvents");
                if(caller == "create" || caller == "update" )
                    $calendar.weekCalendar("updateEvent", calEvent);
                $dialogContent.dialog("close");
            },
            error: function(req, testStatus, errorThrown) {
                alert("Data could not be added properly.\nAre you adding data that overlaps with existing data?\nIf not, get Patrik to investiagte!");
                $dialogContent.dialog("close");
            }
        });
    }

    /*
     * Sets up the start and end time fields in the calendar event
     * form for editing based on the calendar event being edited
     */
    function setupStartAndEndTimeFields($startTimeField, $endTimeField, calEvent, timeslotTimes) {
        $startTimeField.html('');
        $endTimeField.html('');        
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
        if($endTimeOptions.length > timeslotTimes.length) {
            alert("too many options for end field! tell Patrik, he wants to debug this.");
        }
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

    // support functions for getting slightly darker and lighter color variations

    var pad = function(num, totalChars) {
        var pad = '0';
        num = num + '';
        while (num.length < totalChars) {
            num = pad + num;
        }
        return num;
    };

    // Ratio is between 0 and 1
    var changeColor = function(color, ratio, darker) {
        // Trim trailing/leading whitespace
        color = color.replace(/^\s*|\s*$/, '');

        // Expand three-digit hex
        color = color.replace(
            /^#?([a-f0-9])([a-f0-9])([a-f0-9])$/i,
            '#$1$1$2$2$3$3'
        );

        // Calculate ratio
        var difference = Math.round(ratio * 256) * (darker ? -1 : 1),
            // Determine if input is RGB(A)
            rgb = color.match(new RegExp('^rgba?\\(\\s*' +
                '(\\d|[1-9]\\d|1\\d{2}|2[0-4][0-9]|25[0-5])' +
                '\\s*,\\s*' +
                '(\\d|[1-9]\\d|1\\d{2}|2[0-4][0-9]|25[0-5])' +
                '\\s*,\\s*' +
                '(\\d|[1-9]\\d|1\\d{2}|2[0-4][0-9]|25[0-5])' +
                '(?:\\s*,\\s*' +
                '(0|1|0?\\.\\d+))?' +
                '\\s*\\)$'
            , 'i')),
            alpha = !!rgb && rgb[4] != null ? rgb[4] : null,

            // Convert hex to decimal
            decimal = !!rgb? [rgb[1], rgb[2], rgb[3]] : color.replace(
                /^#?([a-f0-9][a-f0-9])([a-f0-9][a-f0-9])([a-f0-9][a-f0-9])/i,
                function() {
                    return parseInt(arguments[1], 16) + ',' +
                        parseInt(arguments[2], 16) + ',' +
                        parseInt(arguments[3], 16);
                }
            ).split(/,/),
            returnValue;

        // Return RGB(A)
        return !!rgb ?
            'rgb' + (alpha !== null ? 'a' : '') + '(' +
                Math[darker ? 'max' : 'min'](
                    parseInt(decimal[0], 10) + difference, darker ? 0 : 255
                ) + ', ' +
                Math[darker ? 'max' : 'min'](
                    parseInt(decimal[1], 10) + difference, darker ? 0 : 255
                ) + ', ' +
                Math[darker ? 'max' : 'min'](
                    parseInt(decimal[2], 10) + difference, darker ? 0 : 255
                ) +
                (alpha !== null ? ', ' + alpha : '') +
                ')' :
            // Return hex
            [
                '#',
                pad(Math[darker ? 'max' : 'min'](
                    parseInt(decimal[0], 10) + difference, darker ? 0 : 255
                ).toString(16), 2),
                pad(Math[darker ? 'max' : 'min'](
                    parseInt(decimal[1], 10) + difference, darker ? 0 : 255
                ).toString(16), 2),
                pad(Math[darker ? 'max' : 'min'](
                    parseInt(decimal[2], 10) + difference, darker ? 0 : 255
                ).toString(16), 2)
            ].join('');
    };
    
    var lighterColor = function(color, ratio) {
        return changeColor(color, ratio, false);
    };
    var darkerColor = function(color, ratio) {
        return changeColor(color, ratio, true);
    };

});
