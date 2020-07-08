<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:html="http://www.w3.org/1999/xhtml" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd html"
    version="3.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This stylesheet moves any <tei:gi>biblScope</tei:gi> from inside <tei:gi>imprint</tei:gi> to its parent <tei:gi>monograph</tei:gi> in order to comply with TEI encoding practices. It also converts the <tei:att>n</tei:att> attribute and its value to identical <tei:att>from</tei:att> and <tei:att>to</tei:att>.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml" omit-xml-declaration="no" version="1.0"/>
    
    <xsl:param name="p_id-editor" select="'pers_TG'"/>
    
    <!-- reproduce everything -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- document the changes -->
    <xsl:template match="tei:revisionDesc" priority="100">
        <xsl:copy>
            <xsl:element name="tei:change">
                <xsl:attribute name="when" select="format-date(current-date(),'[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#',$p_id-editor)"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Corrected </xsl:text><tei:gi>biblStruct</tei:gi><xsl:text> by sorting child elements in the correct order.  Converted all </xsl:text><tei:att>n</tei:att><xsl:text> on </xsl:text><tei:gi>biblScope</tei:gi><xsl:text> to </xsl:text><tei:att>from</tei:att><xsl:text> and </xsl:text><tei:att>to</tei:att><xsl:text>with identical values.</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!--<xsl:template match="tei:biblStruct">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="tei:analytic"/>
            <xsl:apply-templates select="tei:monogr"/>
        </xsl:copy>
    </xsl:template>-->
    <!-- sort the content of monogr -->
    <xsl:template match="tei:monogr">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="tei:title"/>
            <xsl:apply-templates select="tei:idno"/>
            <xsl:apply-templates select="tei:author"/>
            <xsl:apply-templates select="tei:editor"/>
            <xsl:apply-templates select="tei:textLang"/>
            <xsl:apply-templates select="tei:imprint"/>
            <xsl:apply-templates select="tei:biblScope"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- generate @xml:lang -->
    <xsl:template match="tei:monogr[./tei:imprint/tei:biblScope]">
        <xsl:copy>
           <xsl:apply-templates select="@* | node()"/>
            <xsl:apply-templates select="descendant::tei:biblScope"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:imprint[./tei:biblScope]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()[not(ancestor-or-self::tei:biblScope)]"/>
        </xsl:copy>
    </xsl:template>
    <!-- correct the faulty @n attribute -->
    <xsl:template match="tei:biblScope[@n][not(@from)][not(@to)]">
        <xsl:copy>
            <xsl:attribute name="from" select="@n"/>
            <xsl:attribute name="to" select="@n"/>
            <!-- @n should be excluded from reproduction -->
            <xsl:apply-templates select="@*[name()!='n'] | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:listBibl">
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:apply-templates select="tei:biblStruct">
                    <xsl:sort select="descendant::tei:biblScope[@unit='volume']/@from" order="ascending" data-type="number"/>
                    <xsl:sort select="descendant::tei:biblScope[@unit='issue']/@from" order="ascending" data-type="number"/>
                </xsl:apply-templates>
            </xsl:copy>
    </xsl:template>
</xsl:stylesheet>