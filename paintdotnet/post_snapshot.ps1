#
# Paint.NET post snapshot script
# https://github.com/turboapps/turbome/tree/master/paint.net
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0

# Set default program to paint.net.1 and add the same value at the top of OpenWithProgids list for known Paint.NET file associations

Import-Module Turbo

$xappl = Read-XAPPL '.\Import.xappl'

$registry = $xappl.SelectSingleNode('//Configuration/Layers/Layer[@name="Default"]/Registry')
$extensions = '.bmp', '.jpe', '.jpeg', '.jpg', '.pdn', '.png', '.tga'
$extensionNodes = $registry.SelectNodes('./Key[@name="@HKLM@"]/Key[@name="SOFTWARE"]/Key[@name="Classes"]/*') | Where { $extensions -contains $_.name }
foreach ($extensionNode in $extensionNodes) {
    $defaultProgramIdNode = $extensionNode.SelectSingleNode('./Value[@name=""]')
    $defaultProgramIdNode.value = 'paint.net.1'

    $openWithProgidsNode = $extensionNode.SelectSingleNode('./Key[@name="OpenWithProgids"]')
    if ($openWithProgidsNode.FirstChild.name -eq 'paint.net.1') {
        continue
    }
    
    $paintNet1Node = $openWithProgidsNode.SelectSingleNode('./Value[@name="paint.net.1"]')
    if ($paintNet1Node) {
        $openWithProgidsNode.RemoveChild($paintNet1Node)
    } else {
        $paintNet1Node = $xappl.CreateElement('Value')
        $paintNet1Node.isolation = 'Full'
        $paintNet1Node.readOnly = 'False'
        $paintNet1Node.hide = 'False'
        $paintNet1Node.type = 'String'
        $paintNet1Node.value = ''
    }
    $openWithProgidsNode.InsertBefore($paintNet1Node, $openWithProgidsNode.FirstChild);
}

Save-XAPPL $xappl '.\Import.xappl'