$XapplPath = 'C:\output\Snapshot.xappl'
[xml]$xappl = Get-Content $XapplPath
#Create and append first exception
$exceptionNode1 = $xappl.CreateElement("Exception")
$exceptionNode1.SetAttribute("regex","google earth")
$xappl.Configuration.NamedObjectIsolation.AppendChild($exceptionNode1)
#Create and append second exception
$exceptionNode2 = $xappl.CreateElement("Exception")
$exceptionNode2.SetAttribute("regex","shared memory for google earth")
$xappl.Configuration.NamedObjectIsolation.AppendChild($exceptionNode2)
$xappl.Save($XapplPath)
