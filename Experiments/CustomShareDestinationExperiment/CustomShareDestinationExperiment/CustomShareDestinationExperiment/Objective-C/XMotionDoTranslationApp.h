/****************************************************************************************
 * Copyright 2001-2015 Automatic Duck,Inc.  All Rights reserved 
 *
 *
 * XMotionDoTranslation.h  $Revision: 1 $
 *
 *		Description
 *
 *
 ***************************************************************************************/
 
#ifndef _XMotionDoTranslation_H_
# define _XMotionDoTranslation_H_
 
# include "XMotionPreferences.h"

# include "app/DApp.h"
# include "include/TListValue.h"

typedef struct
{
	// (neutral types to make it easy for all to use)
	duckUInt32		warning;// flags...
	duckInt32		fatal;	// omfi fatal error conditions.
	duckInt32		moreInfo ;
} XMotionErrorInfo;

class DTranslateFile ;

class XMotionDoTranslationApp : public DApp
{
  public:
  	XMotionDoTranslationApp(const char *executableName) ;
  	virtual ~XMotionDoTranslationApp() ;
  	
  	// static class methods

	// virtual class methods
	bool		validateInstallationAndActivation() ;	// public method for SN stuff

	duckInt32	translate(DFile inputFile, XMotionPreferences settings) ;

	TListValue<XMotionErrorInfo>&	errorsAndWarnings() { return _duckFileResults ; } ;

	// public member variables
  public:
	
  protected:
	virtual bool updateGlobals( DuckGlobals*, DuckMode* );
	virtual bool updateGlobals( ErrorCode* ) ;
	virtual bool importConversions( TList<ConvertObj>*, ProgressBar*, const DFile& iFile, FileLocation, DFile& outFilePath, DuckGlobals*) ;
#if !USE_CONVERT_OBJ_LIST
		bool importTranslation( DTranslateFile*, ProgressBar*, FileLocation, DFile& outFilePath, DuckGlobals*);
#endif
	
	virtual bool validateInstallation() ;

	TListValue<XMotionErrorInfo>	_duckFileResults ;	// errors + warnings

private:
  	void	init() ;
  
} ;
 
 
 
#endif // _XMotionDoTranslation_H_ 
 
 
/**************************************************************************************
 * $Log: XMotionDoTranslationApp.h $
 * Revision 1 2015/11/24 16:59:31 -0800 harry /FinalCutProX/ADII/harryp
 * init version.
 * 
 *
 *************************************************************************************/
