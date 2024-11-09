/*

    Copyright (c) 2024 Pocketz World. All rights reserved.

    This is a generated file, do not edit!

    Generated by com.pz.studio
*/

#if UNITY_EDITOR

using System;
using System.Linq;
using UnityEngine;
using Highrise.Client;
using Highrise.Studio;
using Highrise.Lua;

namespace Highrise.Lua.Generated
{
    [AddComponentMenu("Lua/PlaceApiaryStatus")]
    [LuaRegisterType(0xe296bc2450435a24, typeof(LuaBehaviour))]
    public class PlaceApiaryStatus : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "b3d1c886ee49c354fb28cdb5798245e7";
        public override string ScriptGUID => s_scriptGUID;


        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), null),
            };
        }
    }
}

#endif