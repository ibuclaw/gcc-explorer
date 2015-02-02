// Copyright (c) 2012-2015, Matt Godbolt
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//     * Redistributions of source code must retain the above copyright notice,
//       this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

import std.stdio;
import std.demangle;
import std.regex;

auto idRegex = ctRegex!(`[_$a-zA-Z][_$a-zA-Z0-9]*`, `g`);
auto sectRegex = ctRegex!(`[0-9]+\s+<(?P<symbol>.*)>:`);
auto disRegex = ctRegex!(`\s+[0-9a-f]+:(?P<assembly>.*)`);

void main() {
    string dem(Captures!(string) m) {
        return demangle(m.hit);
    }

    bool skipSection = false;
    bool skipEmpty = true;

    foreach (line; stdin.byLine()) {
        string s2 = cast(string)line;
        // Ignoring this section.
        if (skipSection) {
            if (s2.length == 0)
                skipSection = false;
            continue;
        }
        // Ignore '/path/foo' and 'Disassembly of section...' lines
        if (s2.length && (s2[0] == '/' || s2[0] == 'D'))
            continue;
        // Ignore initial set of blank lines outputted from objdump.
        if (skipEmpty) {
            if (s2.length == 0)
                continue;
            skipEmpty = false;
        }

        // Get the <symbol> from a section start.
        auto m1 = matchFirst(s2, sectRegex);
        if (m1)
            s2 = m1["symbol"] ~ ":";
        else {
            // Remove prefixing hex locations from assembly.
            auto m2 = matchFirst(s2, disRegex);
            if (m2)
                s2 = m2["assembly"];
        }

        // Skip over .text and other symbol disassemblies.
        if (!skipSection && s2.length && s2[0] == '.') {
            skipSection = true;
            continue;
        }

        auto s = replaceAll!(dem)(s2, idRegex);
        writeln(s);
    }
}
