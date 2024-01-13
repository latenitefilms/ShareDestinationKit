/****************************************************************************************
 * Copyright 2001-2015 Automatic Duck,Inc.  All Rights reserved 
 *
 *
 * XMotionDoTranslation.cpp  $Revision: 1 $
 *
 *		Description
 *
 *
 ***************************************************************************************/
 
#include "XMotionDoTranslationApp.h"

/***************************************************************************************
 *
 *
 */
  
void XMotionDoTranslationApp::init()
{
}

/***************************************************************************************
 *
 *
 */
  
XMotionDoTranslationApp::XMotionDoTranslationApp(const char *executableName) : DApp(executableName)
{
	init() ;
}

XMotionDoTranslationApp::~XMotionDoTranslationApp()
{
}

/***************************************************************************************
 *
 *
 */

bool XMotionDoTranslationApp::updateGlobals(  DuckGlobals *gInfo, DuckMode *mode )
{
	return true ;
}

bool XMotionDoTranslationApp::updateGlobals( ErrorCode *error )
{
	bool rval = true ;
	return rval ;
}

/***************************************************************************************
 *
 *
 */

bool XMotionDoTranslationApp::importConversions(TList<ConvertObj> *conversions, ProgressBar *progress,
									const DFile& inFilePath, FileLocation elocation,
									DFile& outFilePath, DuckGlobals *duckGlobals)
{
#if 0
	// Nothing is done here...
	//
	// All the work is done by the openTheOmfAafFile() method ... it will invoke
	// the CommandHook() [command.cc] callout, and it takes care of EVERYTHING.
	//
	// The AE importer was implemented way before the DApp class hierarchy...
	//
	plog(aeGlobalsStub.debug, "** importConversion() not implemented.\n");
#endif
	DASSERT(0) ;
	return true ;
}

/***************************************************************************************
 *
 *
 */
#if !USE_CONVERT_OBJ_LIST
bool XMotionDoTranslationApp::importTranslation(DTranslationDB&, ProgressBar *progress,
												const DFile& inFilePath, FileLocation elocation,
												DFile& outFilePath, DuckGlobals *duckGlobals)
{
	bool rval = false ;
	DASSERT(0) ;
	return rval ;
}
#endif

/***************************************************************************************
 *
 *
 */

bool XMotionDoTranslationApp::validateInstallation()
{
	bool rval = true;	// dont worry about the installation
	return rval;
}

/**************************************************************************************
 * $Log: XMotionDoTranslationApp.cpp $
 * Revision 1 2015/11/24 16:59:31 -0800 harry /FinalCutProX/ADII/harryp
 * init version.
 * 
 *
 *************************************************************************************/
