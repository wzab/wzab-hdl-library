---
-------------------------------------------------------------------------------
-- MATH_REAL / MOD function - (c)2007 Christophe CURIS
-- Provided as-is as a workaround for GHDL's missing MOD operator on reals
-- Code is GPL.
-------------------------------------------------------------------------------

package math_real_fmod is

function "MOD"(X, Y: in REAL ) return REAL;

end math_real_fmod;

package body math_real_fmod is

function SYS_fmod(X: REAL; Y: REAL) return REAL;
attribute foreign of SYS_fmod : function is "VHPIDIRECT fmod";

function "MOD"(X, Y: in REAL ) return real is
begin
if (Y = 0.0) then
report Y'instance_name & " Y=0.0 not allowed for MOD operator"
severity ERROR;
return 0.0;
else
return SYS_fmod(X, Y);
end if;
end;

function SYS_fmod (X: REAL; Y: REAL) return REAL is
begin
report "ERROR: Call to 'fmod' instead of FOREIGN body"
severity FAILURE;
end SYS_fmod;

end math_real_fmod; 
