<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="3.0"
    xmlns:oape="https://openarabicpe.github.io/ns" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    
    <xsl:include href="../../authority-files/xslt/query-viaf.xsl"/>
    
    <!-- functions -->
    <!-- query a local TEI gazetteer for toponyms, locations, IDs etc. -->
    <xsl:function name="oape:query-gazetteer">
        <!-- input is a tei <placeName> node -->
        <xsl:param name="placeName"/>
        <!-- $gazetteer expects a path to a file -->
        <xsl:param name="gazetteer"/>
        <!-- values for $mode are 'location', 'name', 'type', 'oape' -->
        <xsl:param name="output-mode"/>
        <!-- select a target language for toponyms -->
        <xsl:param name="output-language"/>
        <!-- establish IDs -->
        <xsl:variable name="v_geon-id" select="if(matches($placeName/@ref,'geon:\d+')) then(replace($placeName/@ref,'^.*geon:(\d+).*$','$1')) else('')"/>
        <xsl:variable name="v_oape-id" select="if(matches($placeName/@ref,'oape:place:\d+')) then(replace($placeName/@ref,'^.*oape:place:(\d+).*$','$1')) else('')"/>
        <!-- load data from authority file -->
        <xsl:variable name="v_place">
            <xsl:choose>
                <xsl:when test="$v_oape-id!=''">
                    <xsl:copy-of select="$gazetteer/descendant::tei:place[tei:idno[@type = 'oape'] = $v_oape-id][1]"/>
                </xsl:when>
                <xsl:when test="$v_geon-id!=''">
                    <xsl:copy-of select="$gazetteer/descendant::tei:place[tei:idno[@type = 'geon'] = $v_geon-id][1]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <!-- test for @ref pointing to auhority files -->
            <xsl:when test="$placeName/@ref">
                <!-- debugging message -->
                <xsl:if test="$p_verbose = true()">
                    <xsl:message>
                        <xsl:text>oape:place:</xsl:text><xsl:value-of select="$v_oape-id"/>
                        <xsl:text> </xsl:text>
                        <xsl:text>geon:</xsl:text><xsl:value-of select="$v_geon-id"/>
                    </xsl:message>
                </xsl:if>
                <xsl:choose>
                    <!-- return location -->
                    <xsl:when test="$output-mode = 'location'">
                        <xsl:value-of select="$v_place/descendant-or-self::tei:place/tei:location/tei:geo"/>
                    </xsl:when>
                    <!-- return location -->
                     <xsl:when test="$output-mode = 'oape'">
                        <xsl:value-of select="$v_place/descendant-or-self::tei:place/tei:idno[@type='oape'][1]"/>
                    </xsl:when>
                    <!-- return toponym in selected language -->
                    <xsl:when test="$output-mode = 'name'">
                        <xsl:choose>
                            <xsl:when test="$v_place/descendant-or-self::tei:place/tei:placeName[@xml:lang = $output-language]">
                                <xsl:value-of
                                    select="normalize-space($v_place/descendant-or-self::tei:place/tei:placeName[@xml:lang = $output-language][1])"
                                />
                            </xsl:when>
                            <!-- fallback to english -->
                            <xsl:when test="$v_place/descendant-or-self::tei:place/tei:placeName[@xml:lang = 'en']">
                                <xsl:value-of
                                    select="normalize-space($v_place/descendant-or-self::tei:place/tei:placeName[@xml:lang = 'en'][1])"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space($v_place/descendant-or-self::tei:place/tei:placeName[1])"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- return type -->
                    <xsl:when test="$output-mode = 'type'">
                        <xsl:value-of select="$v_place/descendant-or-self::tei:place/@type"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <!-- return original input toponym if nothing else is fond -->
            <xsl:when test="$output-mode = 'name'">
                <xsl:value-of select="normalize-space($placeName)"/>
            </xsl:when>
            <!-- otherwise: no location data -->
            <xsl:otherwise>
                <xsl:message>
                    <xsl:text>no location data found for </xsl:text><xsl:value-of select="normalize-space($placeName)"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="oape:query-personography">
        <xsl:param name="persName"/>
        <xsl:param name="personography"/>
        <!-- values are 'birth', 'death', 'name', 'wiki', 'viaf', 'oape', 'countWorks' -->
        <xsl:param name="output-mode"/>
        <xsl:param name="output-language"/>
        <!-- establish IDs -->
        <xsl:variable name="v_viaf-id" select="if(matches($persName/@ref,'viaf:\d+')) then(replace($persName/@ref,'^.*viaf:(\d+).*$','$1')) else()"/>
        <xsl:variable name="v_oape-id" select="if(matches($persName/@ref,'oape:pers:\d+')) then(replace($persName/@ref,'^.*oape:pers:(\d+).*$','$1')) else()"/>
        <!--<xsl:message>
            <xsl:text>query personagraphy for </xsl:text><xsl:value-of select="$output-mode"/><xsl:text> of </xsl:text>
            <xsl:text>VIAF ID: </xsl:text><xsl:value-of select="$v_viaf-id"/>
            <xsl:text>, OpenArabicPE ID: </xsl:text><xsl:value-of select="$v_oape-id"/>
        </xsl:message>-->
        <!-- load data from authority file -->
        <xsl:variable name="v_person">
            <xsl:choose>
                <xsl:when test="$v_oape-id!=''">
                    <xsl:copy-of select="$personography/descendant::tei:person[tei:idno[@type = 'oape'] = $v_oape-id][1]"/>
                </xsl:when>
                <xsl:when test="$v_viaf-id!=''">
                    <xsl:copy-of select="$personography/descendant::tei:person[tei:idno[@type = 'viaf'] = $v_viaf-id][1]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!-- test for @ref pointing to VIAF -->
            <xsl:when test="$v_person!=''">
                <xsl:choose>
                    <xsl:when test="$output-mode = 'birth'">
                        <xsl:value-of select="$v_person/descendant-or-self::tei:person/tei:birth/@when"/>
                    </xsl:when>
                    <xsl:when test="$output-mode = 'death'">
                        <xsl:value-of select="$v_person/descendant-or-self::tei:person/tei:death/@when"/>
                    </xsl:when>
                    <xsl:when test="$output-mode = 'name'">
                        <xsl:choose>
                            <!-- preference for names without titles etc. -->
                            <xsl:when test="$v_person/descendant-or-self::tei:person/tei:persName[not(@type = 'flattened')][not(tei:addName)][@xml:lang = $output-language]">
                                <xsl:apply-templates select="$v_person/descendant-or-self::tei:person/tei:persName[not(@type = 'flattened')][not(tei:addName)][not(tei:roleName)][@xml:lang = $output-language][1]" mode="m_plain-text"/>
                            </xsl:when>
                            <!-- fallback to first full name in selected output language-->
                            <xsl:when test="$v_person/descendant-or-self::tei:person/tei:persName[not(@type = 'flattened')][@xml:lang = $output-language]">
                                <xsl:apply-templates select="$v_person/descendant-or-self::tei:person/tei:persName[not(@type = 'flattened')][@xml:lang = $output-language][1]"/>
                            </xsl:when>
                            <!-- fallback to first full name in English -->
                            <xsl:when test="$v_person/descendant-or-self::tei:person/tei:persName[not(@type = 'flattened')][@xml:lang = 'en']">
                                <xsl:apply-templates select="$v_person/descendant-or-self::tei:person/tei:persName[not(@type = 'flattened')][@xml:lang = 'en'][1]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="normalize-space($v_person/descendant-or-self::tei:person/tei:persName[not(@type = 'flattened')][1])"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                     <xsl:when test="$output-mode = 'viaf'">
                        <xsl:value-of select="$v_person/descendant-or-self::tei:person/tei:idno[@type='VIAF'][1]"/>
                    </xsl:when>
                    <xsl:when test="$output-mode = 'oape'">
                        <xsl:value-of select="$v_person/descendant-or-self::tei:person/tei:idno[@type='oape'][1]"/>
                    </xsl:when>
                    <!-- return number of works in viaf -->
                    <xsl:when test="$output-mode = 'countWorks' and $v_viaf-id!=''">
                        <!--<xsl:message>
                            <xsl:text>Query VIAF for number of works of </xsl:text><xsl:value-of select="$v_viaf-id"/>
                        </xsl:message>-->
                        <xsl:variable name="v_person-viaf">
                    <xsl:call-template name="t_query-viaf-sru">
                        <xsl:with-param name="p_input-type" select="'id'"/>
                        <xsl:with-param name="p_search-term" select="$v_viaf-id"/>
                        <xsl:with-param name="p_include-bibliograpy-in-output" select="true()"/>
                        <xsl:with-param name="p_output-mode" select="'tei'"/>
                    </xsl:call-template>
                </xsl:variable>
                         <xsl:value-of select="count($v_person-viaf/descendant::tei:listBibl/tei:bibl)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <!-- return original input name if nothing else is fond -->
            <xsl:when test="$output-mode = 'name'">
                <xsl:value-of select="normalize-space($persName)"/>
            </xsl:when>
            <!-- otherwise: no data -->
            <xsl:otherwise>
                <xsl:message>
                    <xsl:text>no authority data found for </xsl:text><xsl:value-of select="$persName"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- query a local TEI bibliography for titles, editors, locations, IDs etc. -->
    <xsl:function name="oape:query-bibliography">
        <!-- input is a tei <title> node -->
        <xsl:param name="title"/>
        <!-- $bibliography expects a path to a file -->
        <xsl:param name="bibliography"/>
        <!-- $gazetteer expects a path to a file -->
        <xsl:param name="gazetteer"/>
        <!-- values for $p_mode are 'pubPlace', 'location', 'name', 'oape', 'textLang' -->
        <xsl:param name="output-mode"/>
        <!-- select a target language for toponyms -->
        <xsl:param name="output-language"/>
        <!-- establish IDs -->
        <xsl:variable name="v_oclc-id" select="if(matches($title/@ref,'oclc:\d+')) then(replace($title/@ref,'^.*oclc:(\d+).*$','$1')) else('')"/>
        <xsl:variable name="v_oape-id" select="if(matches($title/@ref,'oape:bibl:\d+')) then(replace($title/@ref,'^.*oape:bibl:(\d+).*$','$1')) else('')"/>
        <!-- load data from authority file -->
        <xsl:variable name="v_bibl">
            <xsl:choose>
                <xsl:when test="$v_oape-id!=''">
                    <xsl:copy-of select="$bibliography/descendant::tei:biblStruct[descendant::tei:idno[@type = 'oape'] = $v_oape-id][1]"/>
                </xsl:when>
                <xsl:when test="$v_oclc-id!=''">
                    <xsl:copy-of select="$bibliography/descendant::tei:biblStruct[descendant::tei:idno[@type = 'OCLC'] = $v_oclc-id][1]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <!-- test for @ref pointing to auhority files -->
            <xsl:when test="$title/@ref">
                <!-- debugging message -->
                <xsl:if test="$p_verbose = true()">
                    <xsl:message>
                        <xsl:text>oape:bibl:</xsl:text><xsl:value-of select="$v_oape-id"/>
                        <xsl:text> </xsl:text>
                        <xsl:text>oclc:</xsl:text><xsl:value-of select="$v_oclc-id"/>
                    </xsl:message>
                </xsl:if>
                <!-- the publication place can be further looked up -->
                <xsl:variable name="v_pubPlace" select="$v_bibl/descendant::tei:biblStruct/descendant::tei:pubPlace/tei:placeName[@ref][1]"/>
                <xsl:choose>
                    <!-- return publication place -->
                    <xsl:when test="$output-mode = 'pubPlace'">
                        <xsl:value-of select="oape:query-gazetteer($v_pubPlace,$gazetteer,'name',$output-language)"/>
                    </xsl:when>
                    <!-- return location -->
                    <xsl:when test="$output-mode = 'location'">
                        <xsl:value-of select="oape:query-gazetteer($v_pubPlace,$gazetteer,'location','')"/>
                    </xsl:when>
                    <!-- return IDs -->
                     <xsl:when test="$output-mode = 'oape'">
                        <xsl:value-of select="$v_bibl/descendant::tei:biblStruct/descendant::tei:idno[@type='oape'][1]"/>
                    </xsl:when>
                    <xsl:when test="$output-mode = 'oclc'">
                        <xsl:value-of select="$v_bibl/descendant::tei:biblStruct/descendant::tei:idno[@type='OCLC'][1]"/>
                    </xsl:when>
                    <!-- return the publication title in selected language -->
                    <xsl:when test="$output-mode = 'name'">
                        <xsl:choose>
                            <xsl:when test="$v_bibl/descendant::tei:biblStruct/tei:monogr/tei:title[@xml:lang = $output-language]">
                                <xsl:value-of
                                    select="normalize-space($v_bibl/descendant::tei:biblStruct/tei:monogr/tei:title[@xml:lang = $output-language][1])"
                                />
                            </xsl:when>
                            <!-- fallback to main language of publication -->
                            <xsl:when test="$v_bibl/descendant::tei:biblStruct/tei:monogr/tei:title[@xml:lang = $v_bibl/descendant::tei:biblStruct/tei:monogr/tei:textLang/@mainLang]">
                                <xsl:value-of
                                    select="normalize-space($v_bibl/descendant::tei:biblStruct/tei:monogr/tei:title[@xml:lang = $v_bibl/descendant::tei:biblStruct/tei:monogr/tei:textLang/@mainLang][1])"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space($v_bibl/descendant::tei:biblStruct/tei:monogr/tei:title[1])"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- return type -->
                    <xsl:when test="$output-mode = 'textLang'">
                        <xsl:value-of select="$v_bibl/descendant::tei:biblStruct/tei:monogr/tei:textLang/@mainLang"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <!-- return original input toponym if nothing else is found -->
            <xsl:when test="$output-mode = 'name'">
                <xsl:value-of select="normalize-space($title)"/>
            </xsl:when>
            <!-- otherwise: no location data -->
            <xsl:otherwise>
                <xsl:message>
                    <xsl:text>no bibliographic data found for </xsl:text><xsl:value-of select="normalize-space($title)"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="tei:persName" mode="m_plain-text">
        <xsl:for-each select="descendant::text()">
            <xsl:value-of select="normalize-space()"/>
            <xsl:text> </xsl:text>
        </xsl:for-each>
    </xsl:template>
    <!--<!-\- function to get the author(s) of a div -\->
    <xsl:function name="oape:get-author-from-div">
        <xsl:param name="p_input"/>
         <xsl:choose>
                        <xsl:when test="$p_input/child::tei:byline/descendant::tei:persName[not(ancestor::tei:note)]">
                            <xsl:copy-of select="$p_input/child::tei:byline/descendant::tei:persName[not(ancestor::tei:note)]"/>
                        </xsl:when>
             <xsl:when test="$p_input/child::tei:byline/descendant::tei:orgName[not(ancestor::tei:note)]">
                            <xsl:copy-of select="$p_input/child::tei:byline/descendant::tei:orgName[not(ancestor::tei:note)]"/>
                        </xsl:when>
                        <xsl:when test="$p_input/descendant::tei:note[@type = 'bibliographic']/tei:bibl/tei:author">
                            <xsl:copy-of select="$p_input/descendant::tei:note[@type = 'bibliographic']/tei:bibl/tei:author/descendant::tei:persName"/>
                        </xsl:when>
                        <xsl:when test="$p_input/descendant::tei:note[@type = 'bibliographic']/tei:bibl/tei:title[@level = 'j']">
                            <xsl:copy-of select="$p_input/descendant::tei:note[@type = 'bibliographic']/tei:bibl/tei:title[@level = 'j']"/>
                        </xsl:when>
             <!-\- fallback: NA -\->
             <xsl:otherwise>
                 <xsl:text>NA</xsl:text>
             </xsl:otherwise>
                    </xsl:choose>
    </xsl:function>-->
</xsl:stylesheet>
