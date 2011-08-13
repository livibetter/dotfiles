<!-- 

 This XSLT is used to translate an XML response from the weather.com
 XML API. 

 You can format this file to your liking. Two things you may feel 
 like doing:

	1) Modify the layout of the fields or static text already defined
	2) Add other fields from the XML response file that aren't referenced in this
	   XSLT. You can grab a full list by just doing a: 
           wget "http://xoap.weather.com/weather/local/$LOCID?cc=*&unit=$UNITS" 
           (change $LOCID and $UNITS to suit your needs)
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" > 
	<xsl:output method="text" disable-output-escaping="yes"/>
	<xsl:template match="weather">
		<xsl:apply-templates select="cc"/>
		<xsl:apply-templates select="dayf/day[@d='1']"/>
	</xsl:template>
 
	
	<xsl:template match="cc">
		<xsl:text>Location  : </xsl:text><xsl:value-of select="obst"/>  
<xsl:text>  </xsl:text>
<xsl:text>Temperature: ^fg(#0a0)</xsl:text><xsl:value-of select="tmp"/><xsl:value-of select="/weather/head/ut"/><xsl:text>^fg()</xsl:text>
<xsl:if test="tmp != flik">
<xsl:text>  </xsl:text>
<xsl:text>Feels Like: ^fg(#0a0)</xsl:text><xsl:value-of select="flik"/><xsl:value-of select="/weather/head/ut"/><xsl:text>^fg()</xsl:text>
</xsl:if>
<xsl:text>
Conditions: </xsl:text><xsl:value-of select="t"/>
<xsl:text>   Wind: </xsl:text>
<xsl:choose>
	<xsl:when test="wind/s = 'calm'"><xsl:text>0</xsl:text></xsl:when>
	<xsl:otherwise><xsl:value-of select="wind/s"/></xsl:otherwise>
</xsl:choose>
<xsl:value-of select="/weather/head/us"/> 
<xsl:choose>
	<xsl:when test="wind/s = 'calm'"><xsl:text>(0mph)</xsl:text></xsl:when>
	<xsl:otherwise><xsl:text> (</xsl:text><xsl:value-of select="round(wind/s * 0.6214)"/><xsl:text>mph)</xsl:text></xsl:otherwise>
</xsl:choose>
<xsl:text> (</xsl:text><xsl:value-of select="wind/t"/>
<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template match="dayf/day[@d='1']">
<xsl:text>
Tomorrow  : </xsl:text><xsl:value-of select="low"/><xsl:value-of select="/weather/head/ut"/>
<xsl:text> to </xsl:text><xsl:value-of select="hi"/><xsl:value-of select="/weather/head/ut"/>
<xsl:text> </xsl:text><xsl:value-of select="part[@p='d']/t"/>
<!--<xsl:text>
  </xsl:text><xsl:value-of select="/weather/swa/a/t"/>-->
	</xsl:template>
</xsl:stylesheet>
