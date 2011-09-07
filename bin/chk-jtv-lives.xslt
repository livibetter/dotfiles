<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" disable-output-escaping="yes"/>

<xsl:template match="/">
  <xsl:for-each select="*/stream">
    <xsl:text>ANSI[1;32m</xsl:text>
      <xsl:value-of select="channel/title"/>
    <xsl:text>ANSI[0m</xsl:text>

    <xsl:text> </xsl:text>
      <xsl:value-of select="channel_count"/> 
    <xsl:text> (</xsl:text>
      <xsl:value-of select="embed_count"/>
    <xsl:text> embeds)&#xA;&#xA;</xsl:text>

    <xsl:text>ANSI[1;37m</xsl:text>
    <xsl:choose>
      <xsl:when test="channel/status != ''">
        <xsl:value-of select="channel/status"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[no status]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>ANSI[0m</xsl:text>
    <xsl:text>&#xA;&#xA;</xsl:text>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
