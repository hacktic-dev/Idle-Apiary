/*

    Copyright (c) 2025 Pocketz World. All rights reserved.

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
    [AddComponentMenu("Lua/ApiaryOwnerUi")]
    [LuaRegisterType(0xf8758f6dd7e53d48, typeof(LuaBehaviour))]
    public class ApiaryOwnerUi : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "bb139eae6e51b834aab2a9860d218259";
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
