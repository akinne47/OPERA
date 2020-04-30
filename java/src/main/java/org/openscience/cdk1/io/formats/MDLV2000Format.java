/* $RCSfile$
 * $Author$
 * $Date$
 * $Revision$
 *
 * Copyright (C) 2004-2007  The Chemistry Development Kit (CDK) project
 *
 * Contact: cdk-devel@lists.sourceforge.net
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 */
package org.openscience.cdk1.io.formats;

import org.openscience.cdk1.annotations.TestClass;
import org.openscience.cdk1.annotations.TestMethod;
import org.openscience.cdk1.tools.DataFeatures;

/**
 * @cdk.module ioformats
 * @cdk.githash
 * @cdk.set    io-formats
 */
@TestClass("org.openscience.cdk1.io.formats.MDLV2000FormatTest")
public class MDLV2000Format implements IChemFormatMatcher {

	private static IResourceFormat myself = null;
	
    private MDLV2000Format() {}
    
    @TestMethod("testResourceFormatSet")
    public static IResourceFormat getInstance() {
    	if (myself == null) myself = new MDLV2000Format();
    	return myself;
    }
    
    @TestMethod("testGetFormatName")
    public String getFormatName() {
        return "MDL Molfile V2000";
    }

    @TestMethod("testGetMIMEType")
    public String getMIMEType() {
        return null;
    }
    @TestMethod("testGetPreferredNameExtension")
    public String getPreferredNameExtension() {
        return getNameExtensions()[0];
    }
    @TestMethod("testGetNameExtensions")
    public String[] getNameExtensions() {
        return new String[]{"mol"};
    }

    @TestMethod("testGetReaderClassName")
    public String getReaderClassName() { 
    	return "org.openscience.cdk1.io.MDLV2000Reader";
    }
    @TestMethod("testGetWriterClassName")
    public String getWriterClassName() { 
    	return "org.openscience.cdk1.io.MDLV2000Writer";
    }

    public boolean matches(int lineNumber, String line) {
        if (lineNumber == 4 && 
            (line.indexOf("v2000") >= 0 ||
             line.indexOf("V2000") >= 0)) {
            return true;
        }
        return false;
    }

	@TestMethod("testIsXMLBased")
    public boolean isXMLBased() {
		return false;
	}

	@TestMethod("testGetSupportedDataFeatures")
	public int getSupportedDataFeatures() {
		return getRequiredDataFeatures() |
		       DataFeatures.HAS_2D_COORDINATES |
		       DataFeatures.HAS_3D_COORDINATES |
		       DataFeatures.HAS_GRAPH_REPRESENTATION;
	}

	@TestMethod("testGetRequiredDataFeatures")
    public int getRequiredDataFeatures() {
		return DataFeatures.HAS_ATOM_ELEMENT_SYMBOL;
	}
}