var optprojects = [["all","All"],["phase","Phase"],["participants_filter","Participant filter field"],["project_filter","Project filter field"],["organisation_filter","Organisation filter field"]];
var optparticipants = [["all","All"],["phase","Phase"],["participants_filter","Participant filter field"],["project_filter","Project filter field"],["organisation_filter","Organisation filter field"]];
var optorganisations = [["all","All"],["organisation_type","Organisation type"],["industry","Industry"],["size","Size"]]
var optorganisation_type= [ "Business", "Not for profit", "Membership organisation", "Public sector", "Local Authority", "Incubator / Innovation Cluster", "LEP"]
var optindustry= ["Accounting", "Advertising", "Aerospace",
                "Agriculture", "Aircraft", "Airline",
                "Apparel & Accessories", "Automotive", "Banking",
                "Biotechnology", "Broadcasting", "Chemical",
                "Computer", "Consulting", "Consumer Product",
                "Cosmetics", "Defence", "Education", "Electronics",
                "Energy", "Entertainment & Leisure",
                "Financial Services", "Food & Beverage", "Grocery",
                "Health Care", "Internet Publishing", "Legal",
                "Manufacturing", "Motion Picture & Video", "Music",
                "Newspaper Publishers", "Pharmaceuticals",
                "Publishing","Real Estate", "Retail & Wholesale",
                "Software","Sports", "Technology", "Telecommunication",
                "Television", "Transportation", "Venture Capital"];
var optsize= [ "Less than 10 employees", "11 to 50 employees", "51 to 250 employees", "251 to 1000 employees", "1001 to 10000 employees", "10000+ employees"]
var optorganisation_filter = [["organisation_type","Organisation type"],["industry","Industry"],["size","Size"]]

var optProjects = [["number_of_projects","Number of Projects"]];
var optOrganisations = [["number_of_organisations","Number of Organisations"]];
var optFilteredBy = [["filter_participants","Particpants"],["filter_projects","Projects"],["filter_organisations","Organisations"]];
var optParticipants = [["number_of_participants","Number of Participants"]];
var optEngagement = [["Engagement","Engagement"]];
var optLearning = [["Formal", "Formal"],["Action","Action"],["Social","Social"]];
var optQuality = [["Evaluation", "Evaluation"]]
var optSurvey = [["Survey", "Survey"]]
var optInnerPeople = [["Number of People", "Number of People"]];
var optInnerProjects = [["Number of Projects","Number of Projects"]];
var optInnerOrganisations =  [["Number of Organisations", "Number of Organisations"]];
// var optInnerEngagement = [["Time spent on platform", "Time spent on platform"],["Average user session length","Average user session length"],["Number of likes","Number of likes"],["Number of comments","Number of comments"],["Number of posts on community feed","Number of posts on community feed"], ["Number of events signed up to", "Number of events signed up to"], ["Number of responses to reminders", "Number of responses to reminders"]];
var optInnerEngagement = [["Time spent on platform", "Time spent on platform"],["Number of likes","Number of likes"],["Number of comments","Number of comments"],["Number of posts on community feed","Number of posts on community feed"]];
// var optInnerFormal = [["Number of modules completed","Number of modules completed"],["Number of activities completed","Number of activities completed"],["Hours of content consumed","Hours of content consumed"],["Number of events attended","Number of events attended"]];
var optInnerFormal = [["Number of modules completed","Number of modules completed"],["Number of activities completed","Number of activities completed"],["Hours of content consumed","Hours of content consumed"]];
var optInnerAction = [["Number of tasks completed","Number of tasks completed"],["Number of iterations","Number of iterations"],["Number of times feedback requested","Number of times feedback requested"],["Number of posts on project feed","Number of posts on project feed"]];
var optInnerSocial = [["Number of times feedback received","Number of times feedback received"],["Number of times feedback given","Number of times feedback given"]];
var optInnerEvaluation = [["Rating by judges", "Rating by judges"],["Number of times shortlisted","Number of times shortlisted"],["Number of times won a competition","Number of times won a competition"],["Number of events signed up to","Number of events signed up to"]];
var optInnerSurvey = [["Numerical field", "Numerical field"]];
var optproject_form= [["organisation", "Organisation"]];
var optfilter_participants  = [["particiapant_all", "All"],["particiapant_filter_fields","Filter fields"],["approval_status","Approval Status"]];
var optfilter_projects  = [["project_all", "All"],["project_phase", "Phase"],["project_filter_fields","Custom filter field"]];
var optfilter_organisations  = [["organisation_type","Organisation type"],["industry","Industry"],["size","Size"]];
var optInterval = [["automated_5_quadrants","Automated (5 quadrants automated spread)"],["set_intervals","Set intervals (enter intervals)"]];

function addOptions(optionsData, selectId){
	var options = $('#'+selectId)
	if (optionsData){
		options.empty()
		for (var i = 0; i < optionsData.length; i++) {
		    if (optionsData == optindustry || optionsData == optsize || optionsData == optorganisation_type ){
		      var text = optionsData[i]
		      var val = optionsData[i]
		 	}
		 	else{
		      var text = optionsData[i][1];
		      var val = optionsData[i][0];
		 	}
		     options.append("<option value=\""+ val +"\">" + text + "</option>");
		}
		options.show();
	}
	else{
		options.empty().hide();
	}

};

$(document).ready(function(){
	$("#reporting_who_field_1").change(function(){
		addOptions(window["opt"+$(this).val()], 'reporting_who_field_2');
		$("#reporting_who_field_2").change()
	});
	$("#reporting_who_field_2").change(function(){
		if(($(this).val() == "project_filter") || ($(this).val() == "participants_filter") || ($(this).val() == "phase")){
			custom_field = $(this).val()
			field_url = ($(this).val() == "phase") ? ("phase_fields") : ("filter_custom_field?type="+custom_field)		
        $.ajax({
            url: field_url,
            dataType: "json",
            method: "get",
            success: function( data ) {
            	window["opt"+custom_field] = data
            	addOptions(window["opt"+custom_field], 'reporting_who_field_3');
				$("#reporting_who_field_3").attr("multiple","true","name","reporting[who_field_3][]")
				$("#reporting_who_field_3").attr("name","reporting[who_field_3][]")
                if($.who_field_3_data_multiple){
                    $("#reporting_who_field_3 option").removeAttr("selected")
                    $.each($.who_field_3_data_multiple, function( intIndex, objValue ){
                        $("#reporting_who_field_3 option[value=\""+objValue+"\"]").selected()
                    })
                }
                $("#reporting_who_field_3").change()
            }
        });	                    
		}else{
			$("#reporting_who_field_3").removeAttr("multiple","true")
			addOptions(window["opt"+$(this).val()], 'reporting_who_field_3');
			$("#reporting_who_field_3").attr("name","reporting[who_field_3]")
            if($.who_field_3_data_single){
                $("#reporting_who_field_3").val($.who_field_3_data_single)
            }
			$("#reporting_who_field_3").change()
		}
        $.who_field_3_data_single = ""
        $.who_field_3_data_multiple = ""
	});
	$("#reporting_what_field_1").change(function(){
		addOptions(window["opt"+$(this).val()], 'reporting_what_field_2');
		$("#reporting_what_field_2").change()
	});
	$("#reporting_what_field_2").change(function(){
		addOptions(window["optInner"+$(this).val()], 'reporting_what_field_3');
	});
	$("#reporting_how_field_1").change(function(){
		addOptions(window["opt"+$(this).val()], 'reporting_how_field_2');
		$("#reporting_how_field_2").change()
	});
	$("#reporting_how_field_2").change(function(){
		addOptions(window["opt"+$(this).val()], 'reporting_how_field_3');
		$("#reporting_how_field_3").change()
	});	
	$("#reporting_how_field_2").change(function(){
        if($(this).val() == "set_intervals"){
            $("#reporting_how_field_4").val("").hide()
			$("#reporting_how_field_4").show()
		}
        else if($(this).val() == "automated_5_quadrants"){
            $("#reporting_how_field_4").show()
            $("#reporting_how_field_4").val("1,2,3,4,5").hide()
        }
        else {
			$("#reporting_how_field_4").val("").hide()
		}
        
	});
	$("#reporting_who_field_3").change(function(){
		addOptions(window["opt"+$(this).val()], 'reporting_who_field_4');
	});
});



// Graph draw functions those are using C3 js reusable functions and D3 js library

// Pie Chart Function that can be reused
// example data: pie_chart('#chart',400,680,[["1. Anupam Pitch 1", 1], ["2. Rupali Pitch 3", 1], ["3. Vipul Pitch 1", 2], ["4. Rupali Pitch 1", 2], ["5. Rupali Pitch 2", 3]])
function pie_chart(bind_id,height,width,columns){
    var chart = c3.generate({
        bindto: bind_id,
            size: {
                height: height,
                width: width
            },
            data: {
            columns:
                columns,
            type : 'pie',
            },
            legend: {
                position: 'bottom'
            },
            pie: {
                onclick: function (d, i) { console.log(d, i); },
                onmouseover: function (d, i) { console.log(d, i); },
                onmouseout: function (d, i) { console.log(d, i); }
            }
    }); 
}

// Line Chart Function that can be reused
// example data: line_chart('#chart',340,680,'Participants', 'Projects', [["Projects", 1, 1, 1, 3, 3], ["x", "1. Anupam Jain", "2. Vipul Jain", "3. Vipul Jain", "4. Rupali Jain", "5. Anupam Jain"]], 75, 130, 8)

function line_chart(bind_id,height, width, labelX, labelY, columns, xLabelsRotateDegree, xLabelHeight, culling_max){
    var chart = c3.generate({
        bindto: bind_id,
            size: {
                height: height,
                width: width
            },
            data: {            
                x : 'x',
                columns:
                    columns 
            },
            legend: {
                position: 'right'
            },
            axis: {  
                y: {
                     label: labelY
                },
                x: {
                    label: labelX,
                type: 'category',                        
                tick: {
                    rotate: xLabelsRotateDegree,
                    culling: {
                            max: culling_max // the number of tick texts will be adjusted to less than this value
                        }
                    },
                 height: xLabelHeight
                    },
                }
         }); 
    }
