/*******************************************************************************
 * Copyright (c) 2013, Salesforce.com, Inc.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *     Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *     Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *     Neither the name of Salesforce.com nor the names of its contributors may 
 *     be used to endorse or promote products derived from this software without 
 *     specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************/
grammar PhoenixSQL;

tokens
{
    SELECT='select';
    FROM='from';
    WHERE='where';
    NOT='not';
    AND='and';
    OR='or';
    NULL='null';
    TRUE='true';
    FALSE='false';
    LIKE='like';
    AS='as';
    OUTER='outer';
    ON='on';
    IN='in';
    GROUP='group';
    HAVING='having';
    ORDER='order';
    BY='by';
    ASC='asc';
    DESC='desc';
    NULLS='nulls';
    LIMIT='limit';
    FIRST='first';
    LAST='last';
    CASE='case';
    WHEN='when';
    THEN='then';
    ELSE='else';
    END='end';
    EXISTS='exists';
    IS='is';
    FIRST='first';    
    DISTINCT='distinct';
    JOIN='join';
    INNER='inner';
    LEFT='left';
    RIGHT='right';
    FULL='full';
    BETWEEN='between';
    UPSERT='upsert';
    INTO='into';
    VALUES='values';
    DELETE='delete';
    CREATE='create';
    DROP='drop';
    PRIMARY='primary';
    KEY='key';
    ALTER='alter';
    COLUMN='column';
    TABLE='table';
    ADD='add';
    SPLIT='split';
    EXPLAIN='explain';
    VIEW='view';
    IF='if';
    CONSTRAINT='constraint';
    SHOW='show';
    TABLES='tables';
    ALL='all';
    INDEX='index';
    INCLUDE='include';
    WITHIN='within';
}


@parser::header {
/*******************************************************************************
 * Copyright (c) 2013, Salesforce.com, Inc.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *     Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *     Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *     Neither the name of Salesforce.com nor the names of its contributors may 
 *     be used to endorse or promote products derived from this software without 
 *     specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************/
package com.salesforce.phoenix.parse;

///CLOVER:OFF
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.ListMultimap;
import org.apache.hadoop.hbase.util.Pair;
import java.math.BigDecimal;
import java.util.Arrays;
import java.sql.SQLException;
import com.salesforce.phoenix.expression.function.CountAggregateFunction;
import com.salesforce.phoenix.query.QueryConstants;
import com.salesforce.phoenix.schema.ColumnModifier;
import com.salesforce.phoenix.schema.IllegalDataException;
import com.salesforce.phoenix.schema.PDataType;
import com.salesforce.phoenix.schema.PTableType;
import com.salesforce.phoenix.util.SchemaUtil;
}

@lexer::header {
/*******************************************************************************
 * Copyright (c) 2013, Salesforce.com, Inc.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *     Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *     Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *     Neither the name of Salesforce.com nor the names of its contributors may 
 *     be used to endorse or promote products derived from this software without 
 *     specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************/
package com.salesforce.phoenix.parse;
///CLOVER:OFF
}

// --------------------------------------
// The Parser

@parser::members
{
    
    /**
     * used to turn '?' binds into : binds.
     */
    private int anonBindNum;
    private ParseNodeFactory factory;

    public void setParseNodeFactory(ParseNodeFactory factory) {
        this.factory = factory;
    }
    
    public boolean isCountFunction(String field) {
        return CountAggregateFunction.NORMALIZED_NAME.equals(SchemaUtil.normalizeIdentifier(field));
    }
     
    public int line(Token t) {
        return t.getLine();
    }

    public int column(Token t) {
        return t.getCharPositionInLine() + 1;
    }
    
    private void throwRecognitionException(Token t) throws RecognitionException {
        RecognitionException e = new RecognitionException();
        e.token = t;
        e.line = t.getLine();
        e.charPositionInLine = t.getCharPositionInLine();
        e.input = input;
        throw e;
    }
    
    public int getBindCount() {
        return anonBindNum;
    }
    
    public void resetBindCount() {
        anonBindNum = 0;
    }
    
    public String nextBind() {
        return Integer.toString(anonBindNum++);
    }

    protected Object recoverFromMismatchedToken(IntStream input, int ttype, BitSet follow)
        throws RecognitionException {
        RecognitionException e = null;
        // if next token is what we are looking for then "delete" this token
        if (mismatchIsUnwantedToken(input, ttype)) {
            e = new UnwantedTokenException(ttype, input);
        } else if (mismatchIsMissingToken(input, follow)) {
            Object inserted = getMissingSymbol(input, e, ttype, follow);
            e = new MissingTokenException(ttype, input, inserted);
        } else {
            e = new MismatchedTokenException(ttype, input);
        }
        throw e;
    }

    public Object recoverFromMismatchedSet(IntStream input, RecognitionException e, BitSet follow)
        throws RecognitionException
    {
        throw e;
    }
    
    @Override
    public String getErrorMessage(RecognitionException e, String[] tokenNames) {
        if (e instanceof MismatchedTokenException) {
            MismatchedTokenException mte = (MismatchedTokenException)e;
            String txt = mte.token.getText();
            String p = mte.token.getType() == -1 ? "EOF" : PARAPHRASE[mte.token.getType()];
            String expecting = (mte.expecting < PARAPHRASE.length && mte.expecting >= 0) ? PARAPHRASE[mte.expecting] : null;
            if (expecting == null) {
                return "unexpected token (" + line(mte.token) + "," + column(mte.token) + "): " + (txt != null ? txt : p);
            } else {
                return "expecting " + expecting +
                    ", found '" + (txt != null ? txt : p) + "'";
            }
        } else if (e instanceof NoViableAltException) {
            //NoViableAltException nvae = (NoViableAltException)e;
            return "unexpected token: (" + line(e.token) + "," + column(e.token) + ")" + getTokenErrorDisplay(e.token);
        }
        return super.getErrorMessage(e, tokenNames);
     }

    public String getTokenErrorDisplay(int t) {
        String ret = PARAPHRASE[t];
        if (ret == null) ret = "<UNKNOWN>";
        return ret;
    }


    private String[] PARAPHRASE = new String[getTokenNames().length];
    {
        PARAPHRASE[NAME] = "a field or entity name";
        PARAPHRASE[NUMBER] = "a number";
        PARAPHRASE[EQ] = "an equals sign";
        PARAPHRASE[LT] = "a left angle bracket";
        PARAPHRASE[GT] = "a right angle bracket";
        PARAPHRASE[COMMA] = "a comma";
        PARAPHRASE[LPAREN] = "a left parentheses";
        PARAPHRASE[RPAREN] = "a right parentheses";
        PARAPHRASE[SEMICOLON] = "a semi-colon";
        PARAPHRASE[COLON] = "a colon";
        PARAPHRASE[LSQUARE] = "left square bracket";
        PARAPHRASE[RSQUARE] = "right square bracket";
        PARAPHRASE[LCURLY] = "left curly bracket";
        PARAPHRASE[RCURLY] = "right curly bracket";
        PARAPHRASE[AT] = "at";
        PARAPHRASE[MINUS] = "a subtraction";
        PARAPHRASE[TILDE] = "a tilde";
        PARAPHRASE[PLUS] = "an addition";
        PARAPHRASE[ASTERISK] = "an asterisk";
        PARAPHRASE[DIVIDE] = "a division";
        PARAPHRASE[FIELDCHAR] = "a field character";
        PARAPHRASE[LETTER] = "an ansi letter";
        PARAPHRASE[POSINTEGER] = "a positive integer";
        PARAPHRASE[DIGIT] = "a number from 0 to 9";
    }
}

@rulecatch {
    catch (RecognitionException re) {
        throw re;
    }
}

@lexer::members {

}

// Used to incrementally parse a series of semicolon-terminated SQL statement
// Note than unlike the rule below an EOF is not expected at the end.
nextStatement returns [SQLStatement ret]
    :  s=oneStatement {$ret = s;} SEMICOLON
    |  EOF
    ;

// Parses a single SQL statement (expects an EOF after the select statement).
statement returns [SQLStatement ret]
    :   s=oneStatement {$ret = s;} EOF
    ;

// Parses a select statement which must be the only statement (expects an EOF after the statement).
query returns [SelectStatement ret]
    :   q=select_node EOF {$ret=q;}
    ;

// Parses a single SQL statement (expects an EOF after the select statement).
oneStatement returns [SQLStatement ret]
    :   (q=select_node {$ret=q;} 
    |    u=upsert_node {$ret=u;}
    |    d=delete_node {$ret=d;}
    |    ct=create_table_node {$ret=ct;}
    |    ci=create_index_node {$ret=ci;}
    |    dt=drop_table_node {$ret=dt;}
    |    di=drop_index_node {$ret=di;}
    |    at=alter_table_node {$ret=at;}
    |    e=explain_node {$ret=e;}
    |    st=show_tables_node {$ret=st;}
        )
    ;

show_tables_node returns [SQLStatement ret]
    :   SHOW TABLES {$ret=factory.showTables();}
    ;

explain_node returns [SQLStatement ret]
    :   EXPLAIN q=oneStatement {$ret=factory.explain(q);}
    ;

// Parse a create table statement.
create_table_node returns [CreateTableStatement ret]
    :   CREATE (tt=VIEW | TABLE) (IF NOT ex=EXISTS)? t=from_table_name 
        (LPAREN cdefs=column_defs (pk=pk_constraint)? RPAREN)
        (p=fam_properties)?
        (SPLIT ON v=values)?
        {ret = factory.createTable(t, p, cdefs, pk, v, tt!=null ? PTableType.VIEW : PTableType.USER, ex!=null, getBindCount()); }
    ;

// Parse a create index statement.
create_index_node returns [CreateIndexStatement ret]
    :   CREATE INDEX i=index_name (IF NOT ex=EXISTS)? ON t=from_table_name
        (LPAREN pk=index_pk_constraint RPAREN)
        (INCLUDE (LPAREN icrefs=column_names RPAREN))?
        (p=fam_properties)?
        (SPLIT ON v=values)?
        {ret = factory.createIndex(i, factory.namedTable(null,t), pk, icrefs, v, p, ex!=null, getBindCount()); }
    ;

pk_constraint returns [PrimaryKeyConstraint ret]
    :   CONSTRAINT n=identifier PRIMARY KEY LPAREN cols=col_name_with_mod_list RPAREN { $ret = factory.primaryKey(n,cols); }
    ;

col_name_with_mod_list returns [List<Pair<ColumnName, ColumnModifier>> ret]
@init{ret = new ArrayList<Pair<ColumnName, ColumnModifier>>(); }
    :   p=col_name_with_mod {$ret.add(p);}  (COMMA p = col_name_with_mod {$ret.add(p);} )*
;

col_name_with_mod returns [Pair<ColumnName, ColumnModifier> ret]
    :   f=identifier (order=ASC|order=DESC)? {$ret = Pair.newPair(factory.columnName(f), order == null ? null : ColumnModifier.fromDDLValue(order.getText()));}
;

index_pk_constraint returns [PrimaryKeyConstraint ret]
    :   cols = col_def_name_with_mod_list {$ret = factory.primaryKey(null, cols); }
    ;

col_def_name_with_mod_list returns [List<Pair<ColumnName, ColumnModifier>> ret]
@init{ret = new ArrayList<Pair<ColumnName, ColumnModifier>>(); }
    :   p=col_def_name_with_mod {$ret.add(p);}  (COMMA p = col_def_name_with_mod {$ret.add(p);} )*
;

col_def_name_with_mod returns [Pair<ColumnName, ColumnModifier> ret]
    :   c=column_name (order=ASC|order=DESC)? {$ret = Pair.newPair(c, order == null ? null : ColumnModifier.fromDDLValue(order.getText()));}
;

fam_properties returns [ListMultimap<String,Pair<String,Object>> ret]
@init{ret = ArrayListMultimap.<String,Pair<String,Object>>create(); }
    :  p=fam_prop_name EQ v=prop_value {$ret.put(p.getFamilyName(),new Pair<String,Object>(p.getPropertyName(),v));}  (COMMA p=fam_prop_name EQ v=prop_value {$ret.put(p.getFamilyName(),new Pair<String,Object>(p.getPropertyName(),v));} )*
    ;

fam_prop_name returns [PropertyName ret]
    :   propName=identifier {$ret = factory.propertyName(propName); }
    |   familyName=identifier DOT propName=identifier {$ret = factory.propertyName(familyName, propName); }
    ;
    
prop_value returns [Object ret]
    :   l=literal { $ret = l.getValue(); }
    ;
    
column_name returns [ColumnName ret]
    :   field=identifier {$ret = factory.columnName(field); }
    |   family=identifier DOT field=identifier {$ret = factory.columnName(family, field); }
    ;

column_names returns [List<ColumnName> ret]
@init{ret = new ArrayList<ColumnName>(); }
    :  v = column_name {$ret.add(v);}  (COMMA v = column_name {$ret.add(v);} )*
;

	
// Parse a drop table statement.
drop_table_node returns [DropTableStatement ret]
    :   DROP (v=VIEW | TABLE) (IF ex=EXISTS)? t=from_table_name
        {ret = factory.dropTable(t, v==null ? PTableType.USER : PTableType.VIEW, ex!=null); }
    ;

// Parse a drop index statement
drop_index_node returns [DropIndexStatement ret]
    : DROP INDEX (IF ex=EXISTS)? i=index_name ON t=from_table_name
      {ret = factory.dropIndex(i, t, ex!=null); }
    ;

// Parse an alter table statement.
alter_table_node returns [AlterTableStatement ret]
    :   ALTER TABLE t=from_table_name
        ( (DROP COLUMN (IF ex=EXISTS)? c=column_name) | (ADD (IF NOT ex=EXISTS)? (d=column_def) (p=properties)?) )
        {ret = ( c == null ? factory.addColumn(factory.namedTable(null,t), d, ex!=null, p) : factory.dropColumn(factory.namedTable(null,t), c, ex!=null) ); }
    ;

prop_name returns [String ret]
    :   p=identifier {$ret = p; }
    ;
    
properties returns [Map<String,Object> ret]
@init{ret = new HashMap<String,Object>(); }
    :  k=prop_name EQ v=prop_value {$ret.put(k,v);}  (COMMA k=prop_name EQ v=prop_value {$ret.put(k,v);} )*
    ;

column_defs returns [List<ColumnDef> ret]
@init{ret = new ArrayList<ColumnDef>(); }
    :  v = column_def {$ret.add(v);}  (COMMA v = column_def {$ret.add(v);} )*
;

column_def returns [ColumnDef ret]
    :   c=column_name dt=identifier (LPAREN l=NUMBER (COMMA s=NUMBER)? RPAREN)? (n=NOT? NULL)? (pk=PRIMARY KEY (order=ASC|order=DESC)?)?
        { $ret = factory.columnDef(c, dt, n==null,
            l == null ? null : Integer.parseInt( l.getText() ),
            s == null ? null : Integer.parseInt( s.getText() ),
            pk != null, 
            order == null ? null : ColumnModifier.fromDDLValue(order.getText()) ); }
    ;

dyn_column_defs returns [List<ColumnDef> ret]
@init{ret = new ArrayList<ColumnDef>(); }
    :  v = dyn_column_def {$ret.add(v);}  (COMMA v = dyn_column_def {$ret.add(v);} )*
;

dyn_column_def returns [ColumnDef ret]
    :   c=column_name dt=identifier (LPAREN l=NUMBER (COMMA s=NUMBER)? RPAREN)?
        {$ret = factory.columnDef(c, dt, true,
            l == null ? null : Integer.parseInt( l.getText() ),
            s == null ? null : Integer.parseInt( s.getText() ),
            false, 
            null); }
    ;

dyn_column_name_or_def returns [ColumnDef ret]
    :   c=column_name (dt=identifier (LPAREN l=NUMBER (COMMA s=NUMBER)? RPAREN)? )?
        {$ret = factory.columnDef(c, dt, true,
            l == null ? null : Integer.parseInt( l.getText() ),
            s == null ? null : Integer.parseInt( s.getText() ),
            false, 
            null); }
    ;

// Parses a select statement which must be the only statement (expects an EOF after the statement).
select_expression returns [ParseNode ret]
    :   s=select_node {$ret = factory.subquery(s);}
    ;
    
// Parse a full select expression structure.
select_node returns [SelectStatement ret]
    :   SELECT (hint=hintClause)? (d=DISTINCT | ALL)? sel=select_list
        FROM from=parseFrom
        (WHERE where=condition)?
        (GROUP BY group=group_by)?
        (HAVING having=condition)?
        (ORDER BY order=order_by)?
        (LIMIT l=limit)?
        {$ret = factory.select(from, hint, d!=null, sel, where, group, having, order, l, getBindCount()); }
    ;

// Parse a full upsert expression structure.
upsert_node returns [UpsertStatement ret]
    :   UPSERT INTO t=from_table_name
        (LPAREN p=upsert_column_refs RPAREN)?
        ((VALUES LPAREN v=expression_terms RPAREN) | s=select_node)
        {ret = factory.upsert(factory.namedTable(null,t,p == null ? null : p.getFirst()), p == null ? null : p.getSecond(), v, s, getBindCount()); }
    ;

upsert_column_refs returns [Pair<List<ColumnDef>,List<ColumnName>> ret]
@init{ret = new Pair<List<ColumnDef>,List<ColumnName>>(new ArrayList<ColumnDef>(), new ArrayList<ColumnName>()); }
    :  d=dyn_column_name_or_def { if (d.getDataType()!=null) { $ret.getFirst().add(d); } $ret.getSecond().add(d.getColumnDefName()); } 
       (COMMA d=dyn_column_name_or_def { if (d.getDataType()!=null) { $ret.getFirst().add(d); } $ret.getSecond().add(d.getColumnDefName()); } )*
;
	
// Parses a select statement which must be the only statement (expects an EOF after the statement).
upsert_select_node returns [SelectStatement ret]
    :   s=select_node {$ret = s;}
    ;
    
// Parse a full delete expression structure.
delete_node returns [DeleteStatement ret]
    :   DELETE (hint=hintClause)? FROM t=from_table_name
        (WHERE v=condition)?
        (ORDER BY order=order_by)?
        (LIMIT l=limit)?
        {ret = factory.delete(factory.namedTable(null,t), hint, v, order, l, getBindCount()); }
    ;

limit returns [LimitNode ret]
    : b=bind_expression { $ret = factory.limit(b); }
    | l=int_literal { $ret = factory.limit(l); }
    ;
    
hintClause returns [HintNode ret]
    :  c=ML_HINT { $ret = factory.hint(c.getText()); }
    ;

// Parse the column/expression select list part of a select.
select_list returns [List<AliasedNode> ret]
@init{ret = new ArrayList<AliasedNode>();}
    :   n=selectable {ret.add(n);} (COMMA n=selectable {ret.add(n);})*
    ;

// Parse either a select field or a sub select.
selectable returns [AliasedNode ret]
    :   field=expression (a=parseAlias)? { $ret = factory.aliasedNode(a, field); }
      | familyName=identifier DOT ASTERISK { $ret = factory.aliasedNode(null, factory.family(familyName));} // i.e. the 'cf.*' in 'select cf.* from' cf being column family of an hbase table    
      | ASTERISK { $ret = factory.aliasedNode(null, factory.wildcard());} // i.e. the '*' in 'select * from'    
    ;


// Parse a group by statement
group_by returns [List<ParseNode> ret]
@init{ret = new ArrayList<ParseNode>();}
    :   expr=expression { ret.add(expr); }
        (COMMA expr = expression {ret.add(expr); })*
    ;

// Parse an order by statement
order_by returns [List<OrderByNode> ret]
@init{ret = new ArrayList<OrderByNode>();}
    :   field=parseOrderByField { ret.add(field); }
        (COMMA field = parseOrderByField {ret.add(field); })*
    ;

//parse the individual field for an order by clause
parseOrderByField returns [OrderByNode ret]
@init{boolean isAscending = true; boolean nullsLast = false;}
    :   (expr = expression)
        (ASC {isAscending = true;} | DESC {isAscending = false;})?
        (NULLS (FIRST {nullsLast = false;} | LAST {nullsLast = true;}))?
        { $ret = factory.orderBy(expr, nullsLast, isAscending); }
    ;

parseFrom returns [List<TableNode> ret]
    :   l=table_refs { $ret = l; }
    |   l=join_specs { $ret = l; }   
    ;

table_refs returns [List<TableNode> ret]
@init{ret = new ArrayList<TableNode>(4); }
    :   t=table_ref {$ret.add(t);}
        (COMMA t=table_ref {$ret.add(t);} )*
    ;

// parse a field, if it might be a bind name.
named_table returns [NamedTableNode ret]
    :   t=from_table_name (LPAREN cdefs=dyn_column_defs RPAREN)?  { $ret = factory.namedTable(null,t,cdefs); }
    ;

table_ref returns [TableNode ret]
    :   n=bind_name ((AS)? alias=identifier)? { $ret = factory.bindTable(alias, factory.table(null,n)); } // TODO: review
    |   t=from_table_name ((AS)? alias=identifier)? (LPAREN cdefs=dyn_column_defs RPAREN)? { $ret = factory.namedTable(alias,t,cdefs); }
    |   LPAREN s=select_node RPAREN ((AS)? alias=identifier)? { $ret = factory.subselect(alias, s); }
    ;

join_specs returns [List<TableNode> ret]
    :   t=named_table {$ret.add(t);} (s=join_spec { $ret.add(s); })+
    ;

join_spec returns [JoinTableNode ret]
    :   j=join_type JOIN t=named_table ON e=condition { $ret = factory.join(null, t, e, j); }
    ;

join_type returns [JoinTableNode.JoinType ret]
    :   INNER   { $ret = JoinTableNode.JoinType.Inner; }
    |   LEFT OUTER?   { $ret = JoinTableNode.JoinType.Left; }
    |   RIGHT OUTER?  { $ret = JoinTableNode.JoinType.Right; }
    |   FULL  OUTER?  { $ret = JoinTableNode.JoinType.Full; }
    ;
    
parseAlias returns [String ret]
    :   AS? alias=parseNoReserved { $ret = alias; }
    ;

// Parse a condition, such as used in a where clause - either a basic one, or an OR of (Single or AND) expressions
condition returns [ParseNode ret]
    :   e=condition_or { $ret = e; }
    ;

// A set of OR'd simple expressions
condition_or returns [ParseNode ret]
@init{List<ParseNode> l = new ArrayList<ParseNode>(4); }
    :   i=condition_and {l.add(i);} (OR i=condition_and {l.add(i);})* { $ret = l.size() == 1 ? l.get(0) : factory.or(l); }
    ;

// A set of AND'd simple expressions
condition_and returns [ParseNode ret]
@init{List<ParseNode> l = new ArrayList<ParseNode>(4); }
    :   i=condition_not {l.add(i);} (AND i=condition_not {l.add(i);})* { $ret = l.size() == 1 ? l.get(0) : factory.and(l); }
    ;

// NOT or parenthesis 
condition_not returns [ParseNode ret]
    :   ( boolean_expr ) => e=boolean_expr { $ret = e; }
    |   NOT e=boolean_expr { $ret = factory.not(e); }
    |   LPAREN e=condition RPAREN { $ret = e; }
    ;

boolean_expr returns [ParseNode ret]
    :   (l=expression ((EQ r=expression {$ret = factory.equal(l,r); } )
                  |  ((NOEQ1 | NOEQ2) r=expression {$ret = factory.notEqual(l,r); } )
                  |  (LT r=expression {$ret = factory.lt(l,r); } )
                  |  (GT r=expression {$ret = factory.gt(l,r); } )
                  |  (LT EQ r=expression {$ret = factory.lte(l,r); } )
                  |  (GT EQ r=expression {$ret = factory.gte(l,r); } )
                  |  (IS n=NOT? NULL {$ret = factory.isNull(l,n!=null); } )
                  |  ( n=NOT? ((LIKE r=expression {$ret = factory.like(l,r,n!=null); } )
                      |        (EXISTS LPAREN r=select_expression RPAREN {$ret = factory.exists(l,r,n!=null);} )
                      |        (BETWEEN r1=expression AND r2=expression {$ret = factory.between(l,r1,r2,n!=null); } )
                      |        ((IN ((r=bind_expression {$ret = factory.inList(Arrays.asList(l,r),n!=null);} )
                                | (LPAREN r=select_expression RPAREN {$ret = factory.in(l,r,n!=null);} )
                                | (v=values {List<ParseNode> il = new ArrayList<ParseNode>(v.size() + 1); il.add(l); il.addAll(v); $ret = factory.inList(il,n!=null);})
                                )))
                      ))))
    ;

bind_expression  returns [BindParseNode ret]
    :   b=bind_name { $ret = factory.bind(b); }
    ;
    
expression returns [ParseNode ret]
    :   i=expression_add { $ret = i; }
    ;

expression_add returns [ParseNode ret]
@init{List<ParseNode> l = new ArrayList<ParseNode>(4); }
    :   i=expression_sub {l.add(i);} (PLUS i=expression_sub {l.add(i);})* { $ret = l.size() == 1 ? l.get(0) : factory.add(l); }
    ;

expression_sub returns [ParseNode ret]
@init{List<ParseNode> l = new ArrayList<ParseNode>(4); }
    :   i=expression_concat {l.add(i);} (MINUS i=expression_concat {l.add(i);})* { $ret = l.size() == 1 ? l.get(0) : factory.subtract(l); }
    ;

expression_concat returns [ParseNode ret]
@init{List<ParseNode> l = new ArrayList<ParseNode>(4); }
    :   i=expression_mult {l.add(i);} (CONCAT i=expression_mult {l.add(i);})* { $ret = l.size() == 1 ? l.get(0) : factory.concat(l); }
    ;

expression_mult returns [ParseNode ret]
@init{List<ParseNode> l = new ArrayList<ParseNode>(4); }
    :   i=expression_div {l.add(i);} (ASTERISK i=expression_div {l.add(i);})* { $ret = l.size() == 1 ? l.get(0) : factory.multiply(l); }
    ;

expression_div returns [ParseNode ret]
@init{List<ParseNode> l = new ArrayList<ParseNode>(4); }
    :   i=expression_negate {l.add(i);} (DIVIDE i=expression_negate {l.add(i);})* { $ret = l.size() == 1 ? l.get(0) : factory.divide(l); }
    ;

expression_negate returns [ParseNode ret]
    :   m=MINUS? e=expression_term { $ret = m==null ? e : factory.negate(e); }
    ;

// The lowest level function, which includes literals, binds, but also parenthesized expressions, functions, and case statements.
expression_term returns [ParseNode ret]
@init{ParseNode n;boolean isAscending=true;}
    :   field=identifier oj=OUTER_JOIN? {n = factory.column(field); $ret = oj==null ? n : factory.outer(n); }
    |   tableName=table_name DOT field=identifier oj=OUTER_JOIN? {n = factory.column(tableName, field); $ret = oj==null ? n : factory.outer(n); }
    |   field=identifier LPAREN l=expression_list RPAREN wg=(WITHIN GROUP LPAREN ORDER BY l2=expression_list (ASC {isAscending = true;} | DESC {isAscending = false;}) RPAREN)?{ $ret = wg==null ? factory.function(field, l) : factory.function(field,l,l2,isAscending);} 
    |   field=identifier LPAREN t=ASTERISK RPAREN { if (!isCountFunction(field)) { throwRecognitionException(t); } $ret = factory.function(field, LiteralParseNode.STAR);} 
    |   field=identifier LPAREN t=DISTINCT l=expression_list RPAREN { $ret = factory.functionDistinct(field, l);}
    |   e=expression_literal_bind oj=OUTER_JOIN? { n = e; $ret = oj==null ? n : factory.outer(n); }
    |   e=case_statement { $ret = e; }
    |   LPAREN e=expression RPAREN { $ret = e; }
    ;
    
expression_terms returns [List<ParseNode> ret]
@init{ret = new ArrayList<ParseNode>(); }
    :  v = expression {$ret.add(v);}  (COMMA v = expression {$ret.add(v);} )*
;

index_name returns [NamedNode ret]
    :   name=identifier {$ret = factory.indexName(name); }
    ;

// TODO: figure out how not repeat this two times
table_name returns [TableName ret]
    :   t=identifier {$ret = factory.table(null, t); }
    |   s=identifier DOT t=identifier {$ret = factory.table(s, t); }
    ;

// TODO: figure out how not repeat this two times
from_table_name returns [TableName ret]
    :   t=identifier {$ret = factory.table(null, t); }
    |   s=identifier DOT t=identifier {$ret = factory.table(s, t); }
    ;
    
// The lowest level function, which includes literals, binds, but also parenthesized expressions, functions, and case statements.
expression_literal_bind returns [ParseNode ret]
    :   e=literal { $ret = e; }
    |   b=bind_name { $ret = factory.bind(b); }    
    ;

// Get a string, integer, double, date, boolean, or NULL value.
literal returns [LiteralParseNode ret]
    :   s=STRING_LITERAL { ret = factory.literal(s.getText()); }
    |   n=int_literal { ret = n; }
    |   l=long_literal { ret = l; }
    |   d=DECIMAL {
            try {
                ret = factory.literal(new BigDecimal(d.getText()));
            } catch (NumberFormatException e) { // Shouldn't happen since we just parsed a decimal
                throwRecognitionException(d);
            }
        }
    |   NULL {ret = factory.literal(null);}
    |   TRUE {ret = factory.literal(Boolean.TRUE);} 
    |   FALSE {ret = factory.literal(Boolean.FALSE);}
    ;
    
int_literal returns [LiteralParseNode ret]
    :   n=NUMBER {
            try {
                Long v = Long.valueOf(n.getText());
                if (v >= Integer.MIN_VALUE && v <= Integer.MAX_VALUE) {
                    ret = factory.literal(v.intValue());
                } else {
                    ret = factory.literal(v);
                }
            } catch (NumberFormatException e) { // Shouldn't happen since we just parsed a number
                throwRecognitionException(n);
            }
        }
    ;

long_literal returns [LiteralParseNode ret]
    :   l=LONG {
            try {
                String lt = l.getText();
                Long v = Long.valueOf(lt.substring(0, lt.length() - 1));
                ret = factory.literal(v);
            } catch (NumberFormatException e) { // Shouldn't happen since we just parsed a number
                throwRecognitionException(l);
            }
        }
    ;

values returns [List<ParseNode> ret]
@init{ret = new ArrayList<ParseNode>(); }
    :   LPAREN v = expression_literal_bind {$ret.add(v);}  (COMMA v = expression_literal_bind {$ret.add(v);} )* RPAREN
;

// parse a field, if it might be a bind name.
table returns [String ret]
    :   b=bind_name { $ret = b; }
    |   n=parseNoReserved { $ret = n; }
    ;

// Bind names are a colon followed by 1+ letter/digits/underscores, or '?' (unclear how Oracle acutally deals with this, but we'll just treat it as a special bind)
bind_name returns [String ret]
    :   bname=BIND_NAME { $ret = bname.getText().substring(1); } 
    |   QUESTION { $ret = nextBind(); } // TODO: only support this?
    ;

// Parse a field, includes line and column information.
identifier returns [String ret]
    :   c=parseNoReserved { $ret = c; }
    ;

parseNoReserved returns [String ret]
    :   n=NAME { $ret = n.getText(); }
    ;

expression_list returns [List<ParseNode> ret]
@init{$ret = new ArrayList<ParseNode>();}
    : (e=expression {ret.add(e);})? ( COMMA e=expression {ret.add(e);} )*
    ;

case_statement returns [ParseNode ret]
@init{List<ParseNode> w = new ArrayList<ParseNode>(4);}
    : CASE e1=expression (WHEN e2=expression THEN t=expression {w.add(t);w.add(factory.equal(e1,e2));})+ (ELSE el=expression {w.add(el);})? END {$ret = factory.caseWhen(w);}
    | CASE (WHEN c=condition THEN t=expression {w.add(t);w.add(c);})+ (ELSE el=expression {w.add(el);})? END {$ret = factory.caseWhen(w);}
    ;

// --------------------------------------
// The Lexer

HINT_START: '/*+' ;
COMMENT_START: '/*';
COMMENT_AND_HINT_END: '*/' ;
SL_COMMENT1: '//';
SL_COMMENT2: '--';

// Bind names start with a colon and followed by 1 or more letter/digit/underscores
BIND_NAME
    : COLON (LETTER|DIGIT|'_')+
    ;

// Valid names can have a single underscore, but not multiple
// Turn back on literal testing, all names are literals.
NAME
    :    LETTER (FIELDCHAR)* ('\"' (DBL_QUOTE_CHAR)* '\"')?
    |    '\"' (DBL_QUOTE_CHAR)* '\"'
    ;

// An integer number, positive or negative
NUMBER
    :   POSINTEGER
    ;

LONG
    :   POSINTEGER ('L'|'l')
    ;

// Exponential format is not supported.
DECIMAL
    :   POSINTEGER? '.' POSINTEGER
    ;

DOUBLE
    :   DECIMAL ('D'|'d')
    ;

DOUBLE_QUOTE
    :   '"'
    ;

EQ
    :   '='
    ;

LT
    :   '<'
    ;

GT
    :   '>'
    ;

DOUBLE_EQ
    :   '=''='
    ;

NOEQ1
    :   '!''='
    ;

NOEQ2
    :   '<''>'
    ;

CONCAT
    :   '|''|'
    ;

COMMA
    :   ','
    ;

LPAREN
    :   '('
    ;

RPAREN
    :   ')'
    ;

SEMICOLON
    :   ';'
    ;

COLON
    :   ':'
    ;

QUESTION
    :   '?'
    ;

LSQUARE
    :   '['
    ;

RSQUARE
    :   ']'
    ;

LCURLY
    :   '{'
    ;

RCURLY
    :   '}'
    ;

AT
    :   '@'
    ;

TILDE
    :   '~'
    ;

PLUS
    :   '+'
    ;

MINUS
    :   '-'
    ;

ASTERISK
    :   '*'
    ;

DIVIDE
    :   '/'
    ;

OUTER_JOIN
    : '(' '+' ')'
    ;
// A FieldCharacter is a letter, digit, underscore, or a certain unicode section.
fragment
FIELDCHAR
    :    LETTER
    |    DIGIT
    |    '_'
    |    '\u0080'..'\ufffe'
    ;

// A Letter is a lower or upper case ascii character.
fragment
LETTER
    :    'a'..'z'
    |    'A'..'Z'
    ;

fragment
POSINTEGER
    :   DIGIT+
    ;

fragment
DIGIT
    :    '0'..'9'
    ;

// string literals
STRING_LITERAL
@init{ StringBuilder sb = new StringBuilder(); }
    :   '\''
    ( t=CHAR { sb.append(t.getText()); }
    | t=CHAR_ESC { sb.append(getText()); }
    )* '\'' { setText(sb.toString()); }
    ;

fragment
CHAR
    :   ( ~('\'' | '\\') )+
    ;

fragment
DBL_QUOTE_CHAR
    :   ( ~('\"') )+
    ;

// escape sequence inside a string literal
fragment
CHAR_ESC
    :   '\\'
        ( 'n'   { setText("\n"); }
        | 'r'   { setText("\r"); }
        | 't'   { setText("\t"); }
        | 'b'   { setText("\b"); }
        | 'f'   { setText("\f"); }
        | '\"'  { setText("\""); }
        | '\''  { setText("\'"); }
        | '\\'  { setText("\\"); }
        | '_'   { setText("\\_"); }
        | '%'   { setText("\\\%"); }
        )
    |   '\'\''  { setText("\'"); }
    ;

// whitespace (skip)
WS
    :   ( ' ' | '\t' ) { $channel=HIDDEN; }
    ;
    
EOL
    :  ('\r' | '\n')
    { skip(); }
    ;

ML_HINT
@init{ StringBuilder sb = new StringBuilder(); }
    : HINT_START ( options {greedy=false;} : t=. { sb.append((char)t); } )* COMMENT_AND_HINT_END
    { setText(sb.toString()); }
    ;

ML_COMMENT
    : COMMENT_START (~PLUS) ( options {greedy=false;} : . )* COMMENT_AND_HINT_END
    { skip(); }
    ;

SL_COMMENT
    : (SL_COMMENT1 | SL_COMMENT2) ( options {greedy=false;} : . )* EOL
    { skip(); }
    ;

DOT
    : '.'
    ;

