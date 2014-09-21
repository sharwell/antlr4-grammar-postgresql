/*
 * [The "BSD license"]
 *  Copyright (c) 2014 Terence Parr
 *  Copyright (c) 2014 Sam Harwell
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 *  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package com.tunnelvisionlabs.postgresql.guiplus;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Container;
import java.awt.Desktop;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import javax.imageio.ImageIO;
import javax.swing.Icon;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSlider;
import javax.swing.JSplitPane;
import javax.swing.JTree;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import javax.swing.event.TreeSelectionEvent;
import javax.swing.event.TreeSelectionListener;
import javax.swing.filechooser.FileFilter;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeCellRenderer;
import javax.swing.tree.TreePath;
import javax.swing.tree.TreeSelectionModel;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.misc.JFileChooserConfirmOverwrite;
import org.antlr.v4.runtime.misc.NotNull;
import org.antlr.v4.runtime.misc.Nullable;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.Tree;
import org.antlr.v4.runtime.tree.gui.TreeViewer;

@SuppressWarnings("serial")
public class ExtendedTreeViewer extends TreeViewer {

	public ExtendedTreeViewer(@Nullable List<String> ruleNames, Tree tree) {
		super(ruleNames, tree);
	}

	@NotNull
	protected static JDialog showInDialog(final ExtendedTreeViewer viewer) {
		final JDialog dialog = new JDialog();
		dialog.setTitle("Parse Tree Inspector");

		// Make new content panes
		final Container mainPane = new JPanel(new BorderLayout(5,5));
		final Container contentPane = new JPanel(new BorderLayout(0,0));
		contentPane.setBackground(Color.white);

		// Wrap viewer in scroll pane
		JScrollPane scrollPane = new JScrollPane(viewer);
		// Make the scrollpane (containing the viewer) the center component
		contentPane.add(scrollPane, BorderLayout.CENTER);

		JPanel wrapper = new JPanel(new FlowLayout());

		// Add button to bottom
		JPanel bottomPanel = new JPanel(new BorderLayout(0,0));
		contentPane.add(bottomPanel, BorderLayout.SOUTH);

		JButton ok = new JButton("OK");
		ok.addActionListener(
			new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent e) {
					dialog.setVisible(false);
					dialog.dispose();
				}
			}
		);
		wrapper.add(ok);

		// Add an export-to-png button right of the "OK" button
		JButton png = new JButton("png");
		png.addActionListener(
			new ActionListener() {
				@Override
				public void actionPerformed(ActionEvent e) {
					generatePNGFile(viewer, dialog);
				}
			}
		);
		wrapper.add(png);

		bottomPanel.add(wrapper, BorderLayout.SOUTH);

		// Add scale slider
		int sliderValue = (int) ((viewer.getScale()-1.0) * 1000);
		final JSlider scaleSlider = new JSlider(JSlider.HORIZONTAL,
										  -999,1000,sliderValue);
		scaleSlider.addChangeListener(
			new ChangeListener() {
				@Override
				public void stateChanged(ChangeEvent e) {
					int v = scaleSlider.getValue();
					viewer.setScale(v / 1000.0 + 1.0);
				}
			}
		);
		bottomPanel.add(scaleSlider, BorderLayout.CENTER);

		// Add a JTree representing the parser tree of the input.
		JPanel treePanel = new JPanel(new BorderLayout(5, 5));

		// An "empty" icon that will be used for the JTree's nodes.
		Icon empty = new EmptyIcon();

		UIManager.put("Tree.closedIcon", empty);
		UIManager.put("Tree.openIcon", empty);
		UIManager.put("Tree.leafIcon", empty);

		Tree parseTreeRoot = viewer.getTree().getRoot();
		TreeNodeWrapper nodeRoot = new TreeNodeWrapper(parseTreeRoot, viewer);
		fillTree(nodeRoot, parseTreeRoot, viewer);
		final JTree tree = new JTree(nodeRoot);
		tree.setCellRenderer(new CellRenderer());
		tree.getSelectionModel().setSelectionMode(TreeSelectionModel.SINGLE_TREE_SELECTION);

		tree.addTreeSelectionListener(new TreeSelectionListener() {
			@Override
			public void valueChanged(TreeSelectionEvent e) {

				JTree selectedTree = (JTree) e.getSource();
				TreePath path = selectedTree.getSelectionPath();
				TreeNodeWrapper treeNode = (TreeNodeWrapper) path.getLastPathComponent();

				// Set the clicked AST.
				viewer.setTree((Tree) treeNode.getUserObject());
			}
		});

		treePanel.add(new JScrollPane(tree));

		// Create the pane for both the JTree and the AST
		JSplitPane splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT,
				treePanel, contentPane);

		mainPane.add(splitPane, BorderLayout.CENTER);

		dialog.setContentPane(mainPane);

		// make viz
		dialog.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		dialog.setPreferredSize(new Dimension(600, 500));
		dialog.pack();

		// After pack(): set the divider at 1/3 of the frame.
		splitPane.setDividerLocation(0.33);

		dialog.setLocationRelativeTo(null);
		dialog.setVisible(true);
		return dialog;
	}

	@NotNull
	@Override
	public Future<JDialog> open() {
		final ExtendedTreeViewer viewer = this;
		viewer.setScale(1.5);
		Callable<JDialog> callable = new Callable<JDialog>() {
			JDialog result;

			@Override
			public JDialog call() throws Exception {
				SwingUtilities.invokeAndWait(new Runnable() {
					@Override
					public void run() {
						result = showInDialog(viewer);
					}
				});

				return result;
			}
		};

		ExecutorService executor = Executors.newSingleThreadExecutor();

		try {
			return executor.submit(callable);
		}
		finally {
			executor.shutdown();
		}
	}

	private static void generatePNGFile(TreeViewer viewer, JDialog dialog) {
		BufferedImage bi = new BufferedImage(viewer.getSize().width,
											 viewer.getSize().height,
											 BufferedImage.TYPE_INT_ARGB);
		Graphics g = bi.createGraphics();
		viewer.paint(g);
		g.dispose();

		try {
			File suggestedFile = generateNonExistingPngFile();
			JFileChooser fileChooser = new JFileChooserConfirmOverwrite();
			fileChooser.setCurrentDirectory(suggestedFile.getParentFile());
			fileChooser.setSelectedFile(suggestedFile);
			FileFilter pngFilter = new FileFilter() {

				@Override
				public boolean accept(File pathname) {
					if (pathname.isFile()) {
						return pathname.getName().toLowerCase().endsWith(".png");
					}

					return true;
				}

				@Override
				public String getDescription() {
					return "PNG Files (*.png)";
				}
			};

			fileChooser.addChoosableFileFilter(pngFilter);
			fileChooser.setFileFilter(pngFilter);

			int returnValue = fileChooser.showSaveDialog(dialog);
			if (returnValue == JFileChooser.APPROVE_OPTION) {
				File pngFile = fileChooser.getSelectedFile();
				ImageIO.write(bi, "png", pngFile);

				try {
					// Try to open the parent folder using the OS' native file manager.
					Desktop.getDesktop().open(pngFile.getParentFile());
				}
				catch (Exception ex) {
					// We could not launch the file manager: just show a popup that we
					// succeeded in saving the PNG file.
					JOptionPane.showMessageDialog(dialog, "Saved PNG to: " +
												  pngFile.getAbsolutePath());
					ex.printStackTrace();
				}
			}
		}
		catch (Exception ex) {
			JOptionPane.showMessageDialog(dialog,
										  "Could not export to PNG: " + ex.getMessage(),
										  "Error",
										  JOptionPane.ERROR_MESSAGE);
			ex.printStackTrace();
		}
	}

	private static File generateNonExistingPngFile() {

		final String parent = ".";
		final String name = "antlr4_parse_tree";
		final String extension = ".png";

		File pngFile = new File(parent, name + extension);

		int counter = 1;

		// Keep looping until we create a File that does not yet exist.
		while (pngFile.exists()) {
			pngFile = new File(parent, name + "_"+ counter + extension);
			counter++;
		}

		return pngFile;
	}

	private static void fillTree(TreeNodeWrapper node, Tree tree, ExtendedTreeViewer viewer) {

		if (tree == null) {
			return;
		}

		for (int i = 0; i < tree.getChildCount(); i++) {

			Tree childTree = tree.getChild(i);
			TreeNodeWrapper childNode = new TreeNodeWrapper(childTree, viewer);

			node.add(childNode);

			fillTree(childNode, childTree, viewer);

			if (childNode.hasErrorSubtree) {
				node.hasErrorSubtree = true;
			}
		}
	}

	private static class TreeNodeWrapper extends DefaultMutableTreeNode {

		final ExtendedTreeViewer viewer;
		boolean hasErrorSubtree;

		TreeNodeWrapper(Tree tree, ExtendedTreeViewer viewer) {
			super(tree);
			this.viewer = viewer;
			if (tree instanceof ErrorNode) {
				hasErrorSubtree = true;
			}
			else if (tree instanceof ParserRuleContext) {
				if (((ParserRuleContext)tree).exception != null) {
					hasErrorSubtree = true;
				}
			}
		}

		@Override
		public String toString() {
			return viewer.getText((Tree) this.getUserObject());
		}
	}

	private static class CellRenderer extends DefaultTreeCellRenderer {

		@Override
		public Component getTreeCellRendererComponent(JTree tree, Object value, boolean sel, boolean expanded, boolean leaf, int row, boolean hasFocus) {
			Object actualValue = value;
			if (value instanceof TreeNodeWrapper) {
				TreeNodeWrapper wrapper = (TreeNodeWrapper)value;
				if (wrapper.hasErrorSubtree) {
					actualValue = "<html><span color='red'>" + wrapper.toString() + "</span></html>";
				}
			}

			return super.getTreeCellRendererComponent(tree, actualValue, sel, expanded, leaf, row, hasFocus);
		}

	}

	private static class EmptyIcon implements Icon {

		@Override
		public int getIconWidth() {
			return 0;
		}

		@Override
		public int getIconHeight() {
			return 0;
		}

		@Override
		public void paintIcon(Component c, Graphics g, int x, int y) {
			/* Do nothing. */
		}
	}
}
