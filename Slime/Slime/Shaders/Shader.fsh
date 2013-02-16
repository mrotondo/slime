//
//  Shader.fsh
//  Slime
//
//  Created by Mike Rotondo on 2/16/13.
//  Copyright (c) 2013 Rototyping. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
