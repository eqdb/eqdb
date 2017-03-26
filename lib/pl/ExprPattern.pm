# Copyright (c) 2017, Herman Bergwerf. All rights reserved.
# Use of this source code is governed by an AGPL-3.0-style license
# that can be found in the LICENSE file.

# Algorithm to match expression patterns and rule patterns.
package ExprPattern;
require Exporter;
@ISA        = qw(Exporter);
@EXPORT_OK  = qw(expr_match_pattern expr_match_rule);

use strict;
use warnings;

use ExprUtils qw(debug expr_hash_mix expr_hash_postprocess);

my $EXPR_INTEGER       = 1;
my $EXPR_SYMBOL        = 2;
my $EXPR_SYMBOL_GEN    = 3;
my $EXPR_FUNCTION      = 4;
my $EXPR_FUNCTION_GEN  = 5;

# Compute hash for the given part of the expression data array. Replacing all
# hashes that are in the mapping with the mapped hashes.
sub compute_mapped_hash {
  my ($ptr, $mapping_hash, $data) = @_;

  my $hash = $data->[$ptr++];
  my $type = $data->[$ptr++];
  my $value = $data->[$ptr++];

  if (exists $$mapping_hash{$hash}) {
    return ($$mapping_hash{$hash}, $ptr);
  } elsif ($type == $EXPR_FUNCTION || $type == $EXPR_FUNCTION_GEN) {
    # Hash all arguments together.
    my $argc = $data->[$ptr];
    $ptr += 2;
    debug("compute hash for function with: hash = $hash, argc = $argc\n");
    
    $hash = 0;
    $hash = expr_hash_mix($hash, $type);
    $hash = expr_hash_mix($hash, $value);

    while ($argc > 0) {
      $argc--;
      (my $arg_hash, $ptr) = compute_mapped_hash($ptr, $mapping_hash, $data);
      $hash = expr_hash_mix($hash, $arg_hash);
    }
    return expr_hash_postprocess($hash);
  } else {
    return ($hash, $ptr);
  }
}

# Recursive expression pattern matching.
sub match_pattern {
  my ($write_mapping, $internal_remap, $mapping_hash, $mapping_genfn,
      $ptr_t, $ptr_p, @data) = @_;
    
  my $argc = 1; # arguments left to be processed.

  # Iterate through data untill out of arguments.
  # Returns success if loop completes. If a mismatch is found the function
  # should be terminated directly.
  while ($argc > 0) {
    $argc--;
    
    my $hash_t = $data[$ptr_t++];
    my $hash_p = $data[$ptr_p++];
    my $type_t = $data[$ptr_t++];
    my $type_p = $data[$ptr_p++];
    my $value_t = $data[$ptr_t++];
    my $value_p = $data[$ptr_p++];

    debug(sprintf('target: %s:%s[#%s]', $type_t, $hash_t, $value_t), "\n");
    debug(sprintf('pattern: %s:%s[#%s]', $type_p, $hash_p, $value_p), "\n");
  
    if ($type_p == $EXPR_SYMBOL_GEN) {
      if (!$write_mapping || exists $$mapping_hash{$hash_p}) {
        if ($$mapping_hash{$hash_p} != $hash_t) {
          return 0;
        }
      } else {
        $$mapping_hash{$hash_p} = $hash_t;
      }

      # Jump over function body.
      if ($type_t == $EXPR_FUNCTION || $type_t == $EXPR_FUNCTION_GEN) {
        $ptr_t += 2 + $data[$ptr_t + 1];
      }      
    } elsif ($type_p == $EXPR_FUNCTION_GEN) {
      if (!$write_mapping) {
        # Internal remapping.
        if ($internal_remap) {
          # Disallow generic functions in internal remapping.
          return 0;
        }

        # Retrieve pointers.
        my $ptrs = $$mapping_genfn{$value_p};
        my $mptr_t = $$ptrs[0];
        my $pattern_arg_hash = $$ptrs[2];
        my $pattern_arg_target_hash = $$mapping_hash{$pattern_arg_hash};

        # Compute hash for internal substitution.
        # Overhead of running this when there is no difference is minimal.
        my @result = compute_mapped_hash($ptr_p + 2, $mapping_hash, \@data);
        my $computed_hash = $result[0];
        debug('computed hash: ', $computed_hash, "\n");
        debug('for target: ', $pattern_arg_target_hash, "\n");

        # Deep compare if the computed hash is different.
        if ($computed_hash != $pattern_arg_target_hash) {
          # Temporarily add hash to mapping.
          my $old_hash = $$mapping_hash{$pattern_arg_target_hash};
          $$mapping_hash{$pattern_arg_target_hash} = $computed_hash;

          # Old expression is used as pattern, current expression as target.
          debug("internal remapping start\n");
          if (!match_pattern(0, 1, $mapping_hash, $mapping_genfn,
              $ptr_t - 3, $mptr_t, @data)) {
            return 0;
          }
          debug("internal remapping end\n");

          # Restore old mapping.
          $$mapping_hash{$pattern_arg_target_hash} = $old_hash;
        } else {
          # Shallow compare.
          if ($$mapping_hash{$hash_p} != $hash_t) {
            return 0;
          }
        }
      } else {
        # Validate against existing mapping hash.
        if (exists $$mapping_hash{$hash_p}) {
          if ($$mapping_hash{$hash_p} != $hash_t) {
            return 0;
          }
        } else {
          $$mapping_hash{$hash_p} = $hash_t;

          # Add expression pointer to mapping for later use.
          # Both pointers point at the start of the expression.
          $$mapping_genfn{$value_p} = [$ptr_t - 3, $ptr_p - 3];
        }
      }

      # Jump over function body.
      # Generic functions operating on generic functions are actually bullshit.
      if ($type_t == $EXPR_FUNCTION || $type_t == $EXPR_FUNCTION_GEN) {
        $ptr_t += 2 + $data[$ptr_t + 1];
      }
      $ptr_p += 2 + $data[$ptr_p + 1];
    } elsif ($type_p == $EXPR_SYMBOL) {
      # Check interal remapping caused by generic functions.
      if ($internal_remap && exists $$mapping_hash{$hash_p}) {
        if ($$mapping_hash{$hash_p} != $hash_t) {
          return 0;
        } else {
          # The symbol is in the mapping and matches the given hash. It is
          # possible that the target is a function so now we need to jump over
          # its function body.
          if ($type_t == $EXPR_FUNCTION || $type_t == $EXPR_FUNCTION_GEN) {
            $ptr_t += 2 + $data[$ptr_t + 1];
          }
        }
      } else {
        if ($type_t != $EXPR_SYMBOL || $value_t != $value_p) {
          return 0;
        }
      }
    } elsif ($type_p == $EXPR_FUNCTION) {  
      if ($type_t == $EXPR_FUNCTION && $value_t == $value_p) {
        my $argc_t = $data[$ptr_t++];
        my $argc_p = $data[$ptr_p++];
  
        debug("matching function, argument count: $argc_t, $argc_p\n");
  
        # Both functions must have the same number of arguments.
        if ($argc_t == $argc_p) {
          # Skip content-length.
          $ptr_t++;
          $ptr_p++;
        
          # Add argument count to the total.
          $argc += $argc_p;
        } else {
          # Different number of arguments.
          return 0;
        }
      } else {
        # Pattern is a function but expression is not.
        return 0;
      }
    } elsif ($type_p == $EXPR_INTEGER) {
      # Integers are not very common in patterns. Therefore this is checked
      # last.
      if ($type_t != $EXPR_INTEGER || $value_t != $value_p) {
        return 0;
      }
    } else {
      # Unknown expression type.
      return 0;
    }
  }

  debug("target did match pattern\n");

  # Also return pointer value.
  return (1, $ptr_t, $ptr_p);
}

# Initialization for match_pattern.
sub expr_match_pattern {
  my ($expression, $pattern) = @_;
  my (%mapping_hash, %mapping_genfn);
  my $ptr_t = 0;
  my $ptr_p = scalar(@$expression);
  
  debug('expression: ', join(', ', @$expression), "\n");
  debug('pattern: ', join(', ', @$pattern), "\n");
  
  my $result = match_pattern(1, 0, \%mapping_hash, \%mapping_genfn,
                             $ptr_t, $ptr_p, @$expression, @$pattern);
  return !($result == 0);
}

# Rule matching
# It is possible to put match_pattern inside this function for some very minimal
# gain (arguments do not have to be copied).
sub expr_match_rule {
  my ($expr_left, $expr_right, $rule_left, $rule_right) = @_;
  my (%mapping_hash, %mapping_genfn);
  my $ptr_t = 0;
  my $ptr_p = scalar(@$expr_left) + scalar(@$expr_right);
  my @data = (@$expr_left, @$expr_right, @$rule_left, @$rule_right);
  
  debug("match rule left side\n");
  (my $result_left, $ptr_t, $ptr_p) = match_pattern(
    1, 0, \%mapping_hash, \%mapping_genfn, $ptr_t, $ptr_p, @data);
  if (!$result_left) {
    return 0;
  }

  debug("match rule right side\n");
  # Process generic function mapping.
  foreach my $ptrs (values %mapping_genfn) {
    my $mptr_t = $$ptrs[0];
    my $mptr_p = $$ptrs[1];

    # Get hash of first argument of pattern function.
    # This first argument should be generic.
    my $pattern_arg_hash = $data[$mptr_p + 5];
    push @$ptrs, $pattern_arg_hash;
    
    # If no target hash exists and the expression function has 1 argument, the
    # generic is mapped to that argument.
    if (!exists $mapping_hash{$pattern_arg_hash}) {
      if ($data[$mptr_t + 3] == 1) {
        # Map pattern argument to hash of first expression argument.
        my $hash = $data[$mptr_t + 5];
        debug("infer $hash for pattern $pattern_arg_hash\n");
        $mapping_hash{$pattern_arg_hash} = $hash;
      } else {
        # Argument count not 1, and no target hash exists. So terminate.
        return 0;
      }
    }
  }
  
  my $result_right = match_pattern(
    0, 0, \%mapping_hash, \%mapping_genfn, $ptr_t, $ptr_p, @data);
  return !($result_right == 0);
}

1;
