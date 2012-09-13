# NOM

[![Build Status](https://secure.travis-ci.org/cbeer/nom.png)](http://travis-ci.org/cbeer/nom)

A library to help you tame sprawling XML schemas

NOM allows you to define a “terminology” to ease translation between XML and ruby objects – you can query the xml for Nodes or node values without ever writing a line of XPath.


Some Handy Links
----------------
[API](http://rubydoc.info/github/cbeer/nom) - A reference to NOM's classes
[#projecthydra](http://webchat.freenode.net/?channels=#projecthydra) on irc.freenode.net
[Project Hydra Google Group](http://groups.google.com/group/hydra-tech) - community mailing list and forum

An Example
---------------

```xml
<?xml version="1.0"?>
<!-- from http://www.alistapart.com/d/usingxml/xml_uses_a.html -->
<nutrition>
<food>
	<name>Avocado Dip</name>
	<mfr>Sunnydale</mfr>
	<serving units="g">29</serving>
	<calories total="110" fat="100"/>
	<total-fat>11</total-fat>
	<saturated-fat>3</saturated-fat>
	<cholesterol>5</cholesterol>
	<sodium>210</sodium>
	<carb>2</carb>
	<fiber>0</fiber>
	<protein>1</protein>
	<vitamins>
		<a>0</a>
		<c>0</c>
	</vitamins>
	<minerals>
		<ca>0</ca>
		<fe>0</fe>
	</minerals>
</food>
</nutrition>
```

```ruby
doc = Nokogiri::XML my_source_document

doc.set_terminology do |t|
  t.name

  t.vitamins do |v|
    v.a
    v.c
  end

  t.minerals do |m|
    m.calcium :path => 'ca'
    m.iron :path => 'fe'
  end
end

doc.nom!

doc.name.text == 'Avocado Dip'
doc.minerals.calcium.text == '0'
```



