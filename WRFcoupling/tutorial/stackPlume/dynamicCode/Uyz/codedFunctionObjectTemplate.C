/*---------------------------------------------------------------------------*\
  =========                 |
  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
   \\    /   O peration     | Website:  https://openfoam.org
    \\  /    A nd           | Copyright (C) YEAR OpenFOAM Foundation
     \\/     M anipulation  |
-------------------------------------------------------------------------------
License
    This file is part of OpenFOAM.

    OpenFOAM is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    OpenFOAM is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
    for more details.

    You should have received a copy of the GNU General Public License
    along with OpenFOAM.  If not, see <http://www.gnu.org/licenses/>.

\*---------------------------------------------------------------------------*/

#include "codedFunctionObjectTemplate.H"
#include "volFields.H"
#include "read.H"
#include "addToRunTimeSelectionTable.H"

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

namespace Foam
{

// * * * * * * * * * * * * * * Static Data Members * * * * * * * * * * * * * //

defineTypeNameAndDebug(UyzFunctionObject, 0);

addRemovableToRunTimeSelectionTable
(
    functionObject,
    UyzFunctionObject,
    dictionary
);


// * * * * * * * * * * * * * * * Global Functions  * * * * * * * * * * * * * //

extern "C"
{
    // dynamicCode:
    // SHA1 = 130b8572250d441b8020535fe6dea5587a9db674
    //
    // unique function name that can be checked if the correct library version
    // has been loaded
    void Uyz_130b8572250d441b8020535fe6dea5587a9db674(bool load)
    {
        if (load)
        {
            // code that can be explicitly executed after loading
        }
        else
        {
            // code that can be explicitly executed before unloading
        }
    }
}


// * * * * * * * * * * * * * * * Local Functions * * * * * * * * * * * * * * //

//{{{ begin localCode

//}}} end localCode


// * * * * * * * * * * * * * Private Member Functions  * * * * * * * * * * * //

const fvMesh& UyzFunctionObject::mesh() const
{
    return refCast<const fvMesh>(obr_);
}


// * * * * * * * * * * * * * * * * Constructors  * * * * * * * * * * * * * * //

UyzFunctionObject::UyzFunctionObject
(
    const word& name,
    const Time& runTime,
    const dictionary& dict
)
:
    functionObjects::regionFunctionObject(name, runTime, dict)
{
    read(dict);
}


// * * * * * * * * * * * * * * * * Destructor  * * * * * * * * * * * * * * * //

UyzFunctionObject::~UyzFunctionObject()
{}


// * * * * * * * * * * * * * * * Member Functions  * * * * * * * * * * * * * //

bool UyzFunctionObject::read(const dictionary& dict)
{
    if (false)
    {
        Info<<"read Uyz sha1: 130b8572250d441b8020535fe6dea5587a9db674\n";
    }

//{{{ begin code
    
//}}} end code

    return true;
}


Foam::wordList UyzFunctionObject::fields() const
{
    if (false)
    {
        Info<<"fields Uyz sha1: 130b8572250d441b8020535fe6dea5587a9db674\n";
    }

    wordList fields;
//{{{ begin code
    #line 19 "/home/hilary/OpenFOAM/hilary-13/run/WRFcoupling/tutorial/stackPlume/system/functions/Uyz"

    fields.append("U");

//}}} end code

    return fields;
}


bool UyzFunctionObject::execute()
{
    if (false)
    {
        Info<<"execute Uyz sha1: 130b8572250d441b8020535fe6dea5587a9db674\n";
    }

//{{{ begin code
    
//}}} end code

    return true;
}


bool UyzFunctionObject::write()
{
    if (false)
    {
        Info<<"write Uyz sha1: 130b8572250d441b8020535fe6dea5587a9db674\n";
    }

//{{{ begin code
    #line 10 "/home/hilary/OpenFOAM/hilary-13/run/WRFcoupling/tutorial/stackPlume/system/functions/Uyz"

    volVectorField Uyz
    (
        "Uyz",
        (I - sqr(vector(1, 0, 0))) & mesh().lookupObject<volVectorField>("U")
    );

    Uyz.write();

//}}} end code

    return true;
}


bool UyzFunctionObject::end()
{
    if (false)
    {
        Info<<"end Uyz sha1: 130b8572250d441b8020535fe6dea5587a9db674\n";
    }

//{{{ begin code
    
//}}} end code

    return true;
}


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

} // End namespace Foam

// ************************************************************************* //

