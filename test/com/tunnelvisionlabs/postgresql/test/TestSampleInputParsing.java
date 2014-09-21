/*
 *  Copyright (c) 2014 Sam Harwell, Tunnel Vision Laboratories LLC
 *  All rights reserved.
 * 
 *  The source code of this document is proprietary work, and is not licensed for
 *  distribution or use. For information about licensing, contact Sam Harwell at:
 *      sam@tunnelvisionlabs.com
 */
package com.tunnelvisionlabs.postgresql.test;

import com.tunnelvisionlabs.postgresql.PostgreSqlLexer;
import com.tunnelvisionlabs.postgresql.PostgreSqlLexerUtils;
import com.tunnelvisionlabs.postgresql.PostgreSqlParser;
import com.tunnelvisionlabs.postgresql.PostgreSqlParser.CompilationUnitContext;
import com.tunnelvisionlabs.postgresql.guiplus.ExtendedTreeViewer;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.concurrent.Future;
import javax.swing.JDialog;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.RuleContext;
import org.antlr.v4.runtime.misc.Nullable;
import org.antlr.v4.runtime.misc.Utils;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

/**
 *
 * @author Sam Harwell
 */
@RunWith(Parameterized.class)
public class TestSampleInputParsing {

	private String sourceName;

	public TestSampleInputParsing(String sourceName) {
		this.sourceName = sourceName;
	}

	@Parameterized.Parameters
	public static Collection<String[]> getSources() {
		return Arrays.asList(
			new String[] { "abstime.sql" },
			new String[] { "advisory_lock.sql" },
//			new String[] { "aggregates.sql" }, // COPY FROM STDIN
			new String[] { "alter_generic.sql" },
//			new String[] { "alter_table.sql" }, // COPY FROM STDIN
			new String[] { "arrays.sql" },
			new String[] { "big5.sql" },
//			new String[] { "bit.sql" }, // COPY FROM STDIN
			new String[] { "bitmapops.sql" },
			new String[] { "boolean.sql" },
			new String[] { "box.sql" },
			new String[] { "btree_index.sql" },
			new String[] { "case.sql" },
			new String[] { "char.sql" },
			new String[] { "circle.sql" },
			new String[] { "cluster.sql" },
//			new String[] { "collate.linux.utf8.sql" }, // CAST('42' AS text COLLATE "C")
//			new String[] { "collate.sql" }, // CAST('42' AS text COLLATE "C"), and SELECT COLLATION FOR
			new String[] { "combocid.sql" },
			new String[] { "comments.sql" },
			new String[] { "conversion.sql" },
//			new String[] { "copy2.sql" }, // COPY FROM STDIN
//			new String[] { "copyselect.sql" }, // COPY FROM STDIN
			new String[] { "create_aggregate.sql" },
			new String[] { "create_cast.sql" },
			new String[] { "create_function_3.sql" },
			new String[] { "create_index.sql" },
			new String[] { "create_misc.sql" },
			new String[] { "create_operator.sql" },
			new String[] { "create_table.sql" },
			new String[] { "create_table_like.sql" },
			new String[] { "create_type.sql" },
//			new String[] { "create_view.sql" }, // COPY FROM STDIN
			new String[] { "date.sql" },
			new String[] { "delete.sql" },
			new String[] { "dependency.sql" },
//			new String[] { "domain.sql" }, // COPY FROM STDIN
			new String[] { "drop_if_exists.sql" },
//			new String[] { "enum.sql" }, // COPY FROM STDIN
//			new String[] { "errors.sql" }, // Everything...
			new String[] { "euc_cn.sql" },
			new String[] { "euc_jp.sql" },
			new String[] { "euc_kr.sql" },
			new String[] { "euc_tw.sql" },
			new String[] { "event_trigger.sql" },
			new String[] { "float4.sql" },
			new String[] { "float8.sql" },
			new String[] { "foreign_data.sql" },
			new String[] { "foreign_key.sql" },
			new String[] { "functional_deps.sql" },
			new String[] { "geometry.sql" },
//			new String[] { "guc.sql" }, // SELECT current_user = 'temp_reset_user'
			new String[] { "hash_index.sql" },
			new String[] { "horology.sql" },
			new String[] { "hs_primary_extremes.sql" },
			new String[] { "hs_primary_setup.sql" },
			new String[] { "hs_standby_allowed.sql" },
			new String[] { "hs_standby_check.sql" },
			new String[] { "hs_standby_disallowed.sql" },
			new String[] { "hs_standby_functions.sql" },
			new String[] { "inet.sql" },
			new String[] { "information_schema.sql" },
//			new String[] { "inherit.sql" }, // ORDER BY a.attrelid::regclass::name, a.attnum
			new String[] { "insert.sql" },
			new String[] { "int2.sql" },
			new String[] { "int4.sql" },
			new String[] { "int8.sql" },
//			new String[] { "interval.sql" }, // COPY FROM STDIN
//			new String[] { "join.sql" }, // FROM (J1_TBL CROSS JOIN J2_TBL) AS tx (ii, jj, tt, ii2, kk)
			new String[] { "json.sql" },
			new String[] { "limit.sql" },
			new String[] { "lseg.sql" },
			new String[] { "macaddr.sql" },
			new String[] { "matview.sql" },
			new String[] { "money.sql" },
//			new String[] { "mule_internal.sql" }, // Unknown encoding
			new String[] { "name.sql" },
			new String[] { "namespace.sql" },
//			new String[] { "numeric.sql" }, // COPY FROM STDIN
			new String[] { "numeric_big.sql" },
			new String[] { "numerology.sql" },
			new String[] { "oid.sql" },
			new String[] { "oidjoins.sql" },
			new String[] { "opr_sanity.sql" },
			new String[] { "path.sql" },
			new String[] { "plancache.sql" },
			new String[] { "plperl--1.0.sql" },
			new String[] { "plperl--unpackaged--1.0.sql" },
			new String[] { "plperl.sql" },
			new String[] { "plperlu--1.0.sql" },
			new String[] { "plperlu--unpackaged--1.0.sql" },
			new String[] { "plperlu.sql" },
			new String[] { "plperl_array.sql" },
			new String[] { "plperl_elog.sql" },
			new String[] { "plperl_end.sql" },
			new String[] { "plperl_init.sql" },
			new String[] { "plperl_lc.sql" },
			new String[] { "plperl_plperlu.sql" },
			new String[] { "plperl_shared.sql" },
			new String[] { "plperl_trigger.sql" },
			new String[] { "plperl_util.sql" },
			new String[] { "plpgsql--1.0.sql" },
			new String[] { "plpgsql--unpackaged--1.0.sql" },
//			new String[] { "plpgsql.sql" }, // COPY FROM STDIN
			new String[] { "plpython2u--1.0.sql" },
			new String[] { "plpython2u--unpackaged--1.0.sql" },
			new String[] { "plpython3u--1.0.sql" },
			new String[] { "plpython3u--unpackaged--1.0.sql" },
			new String[] { "plpythonu--1.0.sql" },
			new String[] { "plpythonu--unpackaged--1.0.sql" },
			new String[] { "plpython_composite.sql" },
			new String[] { "plpython_do.sql" },
			new String[] { "plpython_drop.sql" },
			new String[] { "plpython_error.sql" },
			new String[] { "plpython_global.sql" },
			new String[] { "plpython_import.sql" },
			new String[] { "plpython_newline.sql" },
			new String[] { "plpython_params.sql" },
			new String[] { "plpython_populate.sql" },
			new String[] { "plpython_quote.sql" },
			new String[] { "plpython_record.sql" },
			new String[] { "plpython_schema.sql" },
			new String[] { "plpython_setof.sql" },
			new String[] { "plpython_spi.sql" },
			new String[] { "plpython_subtransaction.sql" },
			new String[] { "plpython_test.sql" },
			new String[] { "plpython_trigger.sql" },
			new String[] { "plpython_types.sql" },
			new String[] { "plpython_unicode.sql" },
			new String[] { "plpython_void.sql" },
			new String[] { "pltcl--1.0.sql" },
			new String[] { "pltcl--unpackaged--1.0.sql" },
			new String[] { "pltclu--1.0.sql" },
			new String[] { "pltclu--unpackaged--1.0.sql" },
			new String[] { "pltcl_queries.sql" },
			new String[] { "pltcl_setup.sql" },
			new String[] { "point.sql" },
			new String[] { "polygon.sql" },
			new String[] { "polymorphism.sql" },
			new String[] { "portals.sql" },
			new String[] { "portals_p2.sql" },
			new String[] { "prepare.sql" },
			new String[] { "prepared_xacts.sql" },
//			new String[] { "privileges.sql" }, // COPY FROM STDIN
//			new String[] { "psql.sql" }, // Meta-command overload
			new String[] { "random.sql" },
			new String[] { "rangefuncs.sql" },
			new String[] { "rangetypes.sql" },
			new String[] { "regex.sql" },
			new String[] { "reltime.sql" },
			new String[] { "returning.sql" },
			new String[] { "rowtypes.sql" },
			new String[] { "rules.sql" },
			new String[] { "sanity_check.sql" },
			new String[] { "select.sql" },
			new String[] { "select_distinct.sql" },
			new String[] { "select_distinct_on.sql" },
			new String[] { "select_having.sql" },
			new String[] { "select_implicit.sql" },
			new String[] { "select_into.sql" },
			new String[] { "select_views.sql" },
			new String[] { "sequence.sql" },
			new String[] { "sjis.sql" },
			new String[] { "stats.sql" },
			new String[] { "strings.sql" },
			new String[] { "subselect.sql" },
			new String[] { "system_views.sql" },
			new String[] { "temp.sql" },
			new String[] { "testlibpq2.sql" },
			new String[] { "testlibpq3.sql" },
			new String[] { "text.sql" },
			new String[] { "time.sql" },
			new String[] { "timestamp.sql" },
			new String[] { "timestamptz.sql" },
			new String[] { "timetz.sql" },
			new String[] { "tinterval.sql" },
			new String[] { "transactions.sql" },
			new String[] { "triggers.sql" },
			new String[] { "truncate.sql" },
			new String[] { "tsdicts.sql" },
			new String[] { "tsearch.sql" },
			new String[] { "tstypes.sql" },
			new String[] { "txid.sql" },
			new String[] { "typed_table.sql" },
			new String[] { "type_sanity.sql" },
			new String[] { "union.sql" },
			new String[] { "updatable_views.sql" },
			new String[] { "update.sql" },
			new String[] { "utf8.sql" },
			new String[] { "uuid.sql" },
			new String[] { "vacuum.sql" },
			new String[] { "varchar.sql" },
			new String[] { "window.sql" },
			new String[] { "with.sql" },
			new String[] { "without_oid.sql" },
			new String[] { "xml.sql" },
			new String[] { "xmlmap.sql" }
		);
	}

	@Test
	public void testParsing() throws Exception {
		System.out.println(sourceName + "...");

		String input = loadSample(sourceName, "UTF-8");

		PostgreSqlLexer lexer = PostgreSqlLexerUtils.createLexer(new ANTLRInputStream(input));
		CommonTokenStream tokens = new CommonTokenStream(lexer);
		PostgreSqlParser parser = new PostgreSqlParser(tokens);
		CompilationUnitContext parseTree = parser.compilationUnit();
		if (parser.getNumberOfSyntaxErrors() > 0) {
			JDialog dialog = inspect(parseTree, Arrays.asList(parser.getRuleNames())).get();
			Utils.waitForClose(dialog);
		}
	}

	protected String loadSample(String fileName, String encoding) throws IOException
	{
		if ( fileName==null ) {
			return null;
		}

		String fullFileName = "samples/" + fileName;
		int size = 1024 * 1024;
		InputStreamReader isr;
		InputStream fis = getClass().getClassLoader().getResourceAsStream(fullFileName);
		if ( encoding!=null ) {
			isr = new InputStreamReader(fis, encoding);
		}
		else {
			isr = new InputStreamReader(fis);
		}
		try {
			char[] data = new char[size];
			int n = isr.read(data);
			return new String(data, 0, n);
		}
		finally {
			isr.close();
		}
	}

	protected Future<JDialog> inspect(RuleContext context, @Nullable List<String> ruleNames) {
		ExtendedTreeViewer viewer = new ExtendedTreeViewer(ruleNames, context);
		return viewer.open();
	}
}
