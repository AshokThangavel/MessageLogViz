Class Logs.MessageLogViz Extends %CSP.Page
{

Parameter Title As STRING = "MessageLogViz";

ClassMethod OnPage() As %Status
{
	Do ..OnPageCSPROOT()
	Do ..PrintPage()
	Return $$$OK
}

ClassMethod PrintPage()
{
	Write "<div id=""sidebar"">"
	Write "<h3>IRIS Message Log</h3>"
    Write "<h3>📅 Dates</h3>"

    Set date="",iDate=""
    For {
	    Set date=$O(^||FileDates(date)) q:date=""
	    Write "<a class=""date-item"" data-date="""_date_""" >"_date_"</a>",!
    }
    Write "</div>"
    Write "<div id=""main"">"
    S date=""
	For {
		Set date =$O( ^||filedata(date),-1) Q:date=""
		Set iDate=$O(^||FileDates(iDate))
		Write " <div class=""log-container"" id=""log-"_iDate_""">"
		Write "<div class=""dashboard""></div>"
		Write "<table><thead><tr><th>Time</th><th>Severity</th><th>Module</th><th>Message</th></tr></thead><tbody>"
		Set time=""
		for {
			Set time =$O(^||filedata(date,time)) Q:time=""
			Set counter=""
			For {
				Set counter =$O(^||filedata(date,time,counter),1,data) Q:counter=""
				Set rowcls = $case(+$P(data," ",3),0:"info",2:"error",1:"warning")
				Write !,"<tr class="""_rowcls_""">"
				Write "<td>"_$P(data," ")_"</td>"
				Write "<td>"_$P(data," ",3)_"</td>"
				Write "<td>"_$P(data," ",4)_"</td>"
				Write "<td>"_$P(data," ",5,*)_"</td>"
				Write "</tr>"
			}
		}
		Write !,"</tbody>"
		Write "</table>"
		Write "</div>"
	}

  &HTML<
  <script language="javascript">
    const dateItems = document.querySelectorAll('.date-item');
    const logContainers = document.querySelectorAll('.log-container');

    dateItems.forEach(item => {
      item.addEventListener('click', () => {
        // Remove active class from all
        dateItems.forEach(i => i.classList.remove('active'));
        logContainers.forEach(c => c.classList.remove('active'));

        // Add active to clicked item
        item.classList.add('active');

        // Show the correct log section
        const date = item.getAttribute('data-date');
        const logSection = document.getElementById('log-' + date);
        if (logSection) {
          logSection.classList.add('active');
        }
      });
    });

    // Optional: show first date by default
    if (dateItems.length > 0) {
      dateItems[0].click();
    }
     document.querySelectorAll('td').forEach(td => {
    if (td.textContent.length > 100) {
      td.style.wordWrap = 'break-word';
      td.style.whiteSpace = 'normal';
      td.style.maxWidth = '600px';
    }
  });
  </script>
	>
}

ClassMethod OnPreHTTP() As %Boolean
{
	Do ..CollectLogFileDetails()
	Return $$$OK
}

ClassMethod CollectLogFileDetails()
{
	Set file = $SYSTEM.Util.ManagerDirectory()_"messages.log"
	Set stream = ##class(%Stream.FileCharacter).%New()
 	Set stream.Filename = file,data ="",i=0
	While 'stream.AtEnd {
		Set data=stream.ReadLine()
		Set date = $P($P(data," "),"-")
		s:date'=""&(date["/") ^||FileDates(date)=""
		Do $I(i)
		If $P(data," ")["/" {
			Set ^||filedata(date,$P($P(data," "),"-",2),i)=data
		}
		Else{
			Set ^||filedata(i)=data
		}
	}
	Return $$$OK
}

ClassMethod OnPageCSPROOT() As %Boolean
{
	Do ..OnPageHTML()
}

ClassMethod OnPageHTML() As %Boolean
{
	Write "<html>"
	Write !
	Do ..OnPageHEAD()
	Write !,!
	Write !,"</html>"
}

ClassMethod OnPageHEAD() As %Boolean
{
	Write "<head>"
	Write !,"<title>"_..#Title_"</title>",!
	Write "<style>"
	Do ..LoadCSS()
	Write "</style>"
	Write !,"</head>"
	Do ..HyperEventHead(0,0)
}

ClassMethod LoadCSS()
{
	set obj = ##class(%Dictionary.CompiledXData).%OpenId($Classname()_"||Style")
	return:(obj = "") $$$OK
	set xdata = obj.Data
	set status = ##class(%XML.TextReader).ParseStream(xdata, .textreader)
	while textreader.Read() { if (textreader.NodeType="chars") { write textreader.Value } }
	return $$$OK
}

XData Style
{
<data>
	<![CDATA[body {font-family: Arial, sans-serif;margin: 0;display: flex;height: 100vh;}td.wrap-long-text {max-width: 600px; /* Or any width that makes sense in your layout */ word-wrap: break-word;white-space: normal;}#sidebar {width: 200px;background: #f4f4f4;border-right: 1px solid #ccc;overflow-y: auto;padding: 10px;}#main {flex: 1;padding: 10px;}.date-item {cursor: pointer;padding: 6px;border-bottom: 1px solid #ddd;display: block;text-decoration: none;color: #333;}.date-item:hover {background: #e0e0e0;}.date-item.active {background: #007bff;color: white;}.dashboard {display: flex;gap: 20px;margin-bottom: 15px;}.dashboard div {background: #eee;padding: 10px 15px;border-radius: 4px;font-weight: bold;}table {width: 100%;border-collapse: collapse;font-size: 14px;}th, td {padding: 6px;border: 1px solid #ccc;text-align: left;}.info { background: #f9f9f9; }.warning { background: #fff3cd; }.error { background: #f8d7da; }.log-container {display: none;}.log-container.active {display: block;}]]>
	</data>
}

}
